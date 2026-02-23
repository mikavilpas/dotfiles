use anyhow::{anyhow, bail};

use crate::gitlab::gitlab_mrs::mr_tree::{
    self,
    mr_tree_breadth_first_iterator::{Depth, MrNodeBreadthFirstIterator},
};

use super::MergeRequest;

pub fn format_mr_stack_as_markdown(
    mrs: Vec<MergeRequest>,
    current_branch: &str,
) -> anyhow::Result<String> {
    let mrs = match mr_tree::treeify_mrs(mrs)? {
        mr_tree::TreeifyResult::Ok(mr_tree) => mr_tree,
        mr_tree::TreeifyResult::NoOpenMergeRequests => bail!("No open merge requests."),
    };

    // Generate markdown
    let mut output = String::from("");

    let mut iterator = MrNodeBreadthFirstIterator::new(&mrs);

    // get the first mr in the stack so we always start from the bottom of the stack. This way we
    // can output the full stack even if the current branch is not the root of the stack.
    let stack_root = {
        let current_node = iterator
            .find(|stack_node| stack_node.mr.mr.source_branch == current_branch)
            .ok_or_else(|| {
                anyhow!(
                    "Current branch '{}' is not the source branch of any open MR.",
                    current_branch
                )
            })?;

        mrs.find_root_of(current_node.index)
    };

    // format each mr in the stack
    format_mr_stack(&mrs, stack_root, current_branch, Depth(0), &mut output);

    Ok(output.trim_end().to_string())
}

fn format_mr_stack(
    tree: &mr_tree::MrTree,
    idx: mr_tree::MrNodeIndex,
    current_branch: &str,
    depth: Depth,
    output: &mut String,
) {
    let Some(node) = tree.get(idx) else {
        return;
    };
    let mr = &node.mr;
    let is_current = mr.source_branch == current_branch;

    // Indentation
    let indent = "  ".repeat(depth.0);

    // Add **Draft:** prefix if draft, cleaning up the title
    let title_display = if mr.draft {
        // Remove "Draft: " prefix from title if present (GitLab often includes it)
        let clean_title = mr
            .title
            .strip_prefix("Draft: ")
            .or_else(|| mr.title.strip_prefix("Draft:"))
            .or_else(|| mr.title.strip_prefix("WIP: "))
            .unwrap_or(&mr.title);
        format!("**Draft:** {}", clean_title)
    } else {
        mr.title.clone()
    };

    if is_current {
        output.push_str(&format!(
            "{}- 👉🏻 **[!{}]({}) {}** 👈🏻\n",
            indent, mr.iid, mr.web_url, title_display
        ));
    } else {
        output.push_str(&format!(
            "{}- [!{}]({}) {}\n",
            indent, mr.iid, mr.web_url, title_display
        ));
    }

    // Sort children by iid ascending and recurse
    let mut sorted_children = node.children.clone();
    sorted_children.sort_by_key(|&i| tree.get(i).map(|n| n.mr.iid).unwrap_or(0));

    for &child_idx in &sorted_children {
        format_mr_stack(tree, child_idx, current_branch, Depth(depth.0 + 1), output);
    }
}

#[cfg(test)]
mod tests {
    use pretty_assertions::assert_eq;

    use crate::gitlab::gitlab_mrs::mr_stack;

    use super::*;

    #[test]
    fn test_format_mr_stack_as_markdown() -> Result<(), Box<dyn std::error::Error>> {
        let first_branch = "feature-101";
        let second_branch = "feature-102";
        let mrs = Vec::from([
            MergeRequest {
                iid: 101,
                title: "feat: base feature".to_string(),
                web_url: "https://gitlab.example.com/acme/webapp/-/merge_requests/101".to_string(),
                source_branch: first_branch.to_string(),
                target_branch: "main".to_string(),
                draft: false,
            },
            MergeRequest {
                iid: 102,
                title: "feat: dependent feature".to_string(),
                web_url: "https://gitlab.example.com/acme/webapp/-/merge_requests/102".to_string(),
                source_branch: second_branch.to_string(),
                target_branch: first_branch.to_string(), // targets 101's source
                draft: false,
            },
            MergeRequest {
                iid: 103,
                title: "fix: bug in dependent feature".to_string(),
                web_url: "https://gitlab.example.com/acme/webapp/-/merge_requests/103".to_string(),
                source_branch: "feature-103".to_string(),
                target_branch: second_branch.to_string(), // targets 102's source
                draft: true,                              // This one is a draft
            },
        ]);

        // should render the full stack regardless of which branch we're on,
        // with the current branch's MR bolded
        let output_from_root = mr_stack::format_mr_stack_as_markdown(mrs.clone(), first_branch)?;
        assert_eq!(
            output_from_root,
            [
                "- 👉🏻 **[!101](https://gitlab.example.com/acme/webapp/-/merge_requests/101) feat: base feature** 👈🏻",
                "  - [!102](https://gitlab.example.com/acme/webapp/-/merge_requests/102) feat: dependent feature",
                "    - [!103](https://gitlab.example.com/acme/webapp/-/merge_requests/103) **Draft:** fix: bug in dependent feature",
            ].join("\n")
        );

        let output_from_middle = mr_stack::format_mr_stack_as_markdown(mrs.clone(), second_branch)?;
        assert_eq!(
            output_from_middle,
            [
                "- [!101](https://gitlab.example.com/acme/webapp/-/merge_requests/101) feat: base feature",
                "  - 👉🏻 **[!102](https://gitlab.example.com/acme/webapp/-/merge_requests/102) feat: dependent feature** 👈🏻",
                "    - [!103](https://gitlab.example.com/acme/webapp/-/merge_requests/103) **Draft:** fix: bug in dependent feature",
            ].join("\n")
        );

        let output_from_leaf = mr_stack::format_mr_stack_as_markdown(mrs, "feature-103")?;
        assert_eq!(
            output_from_leaf,
            [
                "- [!101](https://gitlab.example.com/acme/webapp/-/merge_requests/101) feat: base feature",
                "  - [!102](https://gitlab.example.com/acme/webapp/-/merge_requests/102) feat: dependent feature",
                "    - 👉🏻 **[!103](https://gitlab.example.com/acme/webapp/-/merge_requests/103) **Draft:** fix: bug in dependent feature** 👈🏻",
            ].join("\n")
        );

        Ok(())
    }

    /// Tree structure:
    ///
    /// ```text
    /// main <- A (101)
    ///           ├── B (102) <- C (103)
    ///           └── D (104)
    /// main <- X (105) <- Y (106)
    /// ```
    ///
    /// When on branch B, should show the full A subtree (including sibling D),
    /// but not the unrelated X/Y stack.
    #[test]
    fn test_branching_tree_with_sibling_and_unrelated_stack()
    -> Result<(), Box<dyn std::error::Error>> {
        let url =
            |iid: u64| format!("https://gitlab.example.com/acme/webapp/-/merge_requests/{iid}");
        let mr = |iid: u64, title: &str, source: &str, target: &str| MergeRequest {
            iid,
            title: title.to_string(),
            web_url: url(iid),
            source_branch: source.to_string(),
            target_branch: target.to_string(),
            draft: false,
        };

        let mrs = Vec::from([
            mr(101, "feat: base feature", "feature-a", "main"),
            mr(102, "feat: add API layer", "feature-b", "feature-a"),
            mr(103, "feat: add tests for API", "feature-c", "feature-b"),
            mr(104, "feat: docs for base", "feature-d", "feature-a"),
            // unrelated stack
            mr(105, "chore: CI setup", "feature-x", "main"),
            mr(106, "chore: add linting", "feature-y", "feature-x"),
        ]);

        // on feature-b: should show A's full subtree (B, C, D) but not X/Y
        let output = mr_stack::format_mr_stack_as_markdown(mrs.clone(), "feature-b")?;
        assert_eq!(
            output,
            format!(
                "\
- [!101]({}) feat: base feature
  - 👉🏻 **[!102]({}) feat: add API layer** 👈🏻
    - [!103]({}) feat: add tests for API
  - [!104]({}) feat: docs for base",
                url(101),
                url(102),
                url(103),
                url(104),
            )
        );

        // on feature-y: should show only the X/Y stack
        let output = mr_stack::format_mr_stack_as_markdown(mrs.clone(), "feature-y")?;
        assert_eq!(
            output,
            format!(
                "\
- [!105]({}) chore: CI setup
  - 👉🏻 **[!106]({}) chore: add linting** 👈🏻",
                url(105),
                url(106),
            )
        );

        // on feature-a: should show A's full subtree, not X/Y
        let output = mr_stack::format_mr_stack_as_markdown(mrs, "feature-a")?;
        assert_eq!(
            output,
            format!(
                "\
- 👉🏻 **[!101]({}) feat: base feature** 👈🏻
  - [!102]({}) feat: add API layer
    - [!103]({}) feat: add tests for API
  - [!104]({}) feat: docs for base",
                url(101),
                url(102),
                url(103),
                url(104),
            )
        );

        Ok(())
    }
}
