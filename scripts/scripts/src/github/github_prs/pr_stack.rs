use anyhow::{anyhow, bail};

use crate::github::github_prs::pr_tree::{
    self,
    pr_tree_breadth_first_iterator::{Depth, PrNodeBreadthFirstIterator},
};

use super::PullRequest;

pub fn format_pr_stack_as_markdown(
    prs: Vec<PullRequest>,
    current_branch: &str,
) -> anyhow::Result<String> {
    let prs = match pr_tree::treeify_prs(prs)? {
        pr_tree::TreeifyResult::Ok(pr_tree) => pr_tree,
        pr_tree::TreeifyResult::NoOpenPullRequests => bail!("No open pull requests."),
    };

    let mut output = String::from("");

    let mut iterator = PrNodeBreadthFirstIterator::new(&prs);

    let stack_root = {
        let current_node = iterator
            .find(|stack_node| stack_node.pr.pr.head_ref_name == current_branch)
            .ok_or_else(|| {
                anyhow!(
                    "Current branch '{}' is not the head branch of any open PR.",
                    current_branch
                )
            })?;

        prs.find_root_of(current_node.index)
    };

    format_pr_stack(&prs, stack_root, current_branch, Depth(0), &mut output);

    Ok(output.trim_end().to_string())
}

fn format_pr_stack(
    tree: &pr_tree::PrTree,
    idx: pr_tree::PrNodeIndex,
    current_branch: &str,
    depth: Depth,
    output: &mut String,
) {
    let Some(node) = tree.get(idx) else {
        return;
    };
    let pr = &node.pr;
    let is_current = pr.head_ref_name == current_branch;

    let indent = "  ".repeat(depth.0);

    let title_display = if pr.is_draft {
        let clean_title = pr
            .title
            .strip_prefix("Draft: ")
            .or_else(|| pr.title.strip_prefix("Draft:"))
            .unwrap_or(&pr.title);
        format!("**Draft:** {}", clean_title)
    } else {
        pr.title.clone()
    };

    if is_current {
        output.push_str(&format!(
            "{}- 👉🏻 **[#{}]({})** | {} 👈🏻\n",
            indent, pr.number, pr.url, title_display
        ));
    } else {
        output.push_str(&format!(
            "{}- [#{}]({}) | {}\n",
            indent, pr.number, pr.url, title_display
        ));
    }

    let mut sorted_children = node.children.clone();
    sorted_children.sort_by_key(|&i| tree.get(i).map(|n| n.pr.number).unwrap_or(0));

    for &child_idx in &sorted_children {
        format_pr_stack(tree, child_idx, current_branch, Depth(depth.0 + 1), output);
    }
}

#[cfg(test)]
mod tests {
    use pretty_assertions::assert_eq;

    use crate::github::github_prs::pr_stack;

    use super::*;

    #[test]
    fn test_format_pr_stack_as_markdown() -> Result<(), Box<dyn std::error::Error>> {
        let first_branch = "feature-101";
        let second_branch = "feature-102";
        let prs = Vec::from([
            PullRequest {
                number: 101,
                title: "feat: base feature".to_string(),
                url: "https://github.com/acme/webapp/pull/101".to_string(),
                head_ref_name: first_branch.to_string(),
                base_ref_name: "main".to_string(),
                is_draft: false,
            },
            PullRequest {
                number: 102,
                title: "feat: dependent feature".to_string(),
                url: "https://github.com/acme/webapp/pull/102".to_string(),
                head_ref_name: second_branch.to_string(),
                base_ref_name: first_branch.to_string(),
                is_draft: false,
            },
            PullRequest {
                number: 103,
                title: "fix: bug in dependent feature".to_string(),
                url: "https://github.com/acme/webapp/pull/103".to_string(),
                head_ref_name: "feature-103".to_string(),
                base_ref_name: second_branch.to_string(),
                is_draft: true,
            },
        ]);

        let output_from_root = pr_stack::format_pr_stack_as_markdown(prs.clone(), first_branch)?;
        assert_eq!(
            output_from_root,
            [
                "- 👉🏻 **[#101](https://github.com/acme/webapp/pull/101)** | feat: base feature 👈🏻",
                "  - [#102](https://github.com/acme/webapp/pull/102) | feat: dependent feature",
                "    - [#103](https://github.com/acme/webapp/pull/103) | **Draft:** fix: bug in dependent feature",
            ].join("\n")
        );

        let output_from_middle = pr_stack::format_pr_stack_as_markdown(prs.clone(), second_branch)?;
        assert_eq!(
            output_from_middle,
            [
                "- [#101](https://github.com/acme/webapp/pull/101) | feat: base feature",
                "  - 👉🏻 **[#102](https://github.com/acme/webapp/pull/102)** | feat: dependent feature 👈🏻",
                "    - [#103](https://github.com/acme/webapp/pull/103) | **Draft:** fix: bug in dependent feature",
            ].join("\n")
        );

        let output_from_leaf = pr_stack::format_pr_stack_as_markdown(prs, "feature-103")?;
        assert_eq!(
            output_from_leaf,
            [
                "- [#101](https://github.com/acme/webapp/pull/101) | feat: base feature",
                "  - [#102](https://github.com/acme/webapp/pull/102) | feat: dependent feature",
                "    - 👉🏻 **[#103](https://github.com/acme/webapp/pull/103)** | **Draft:** fix: bug in dependent feature 👈🏻",
            ].join("\n")
        );

        Ok(())
    }

    #[test]
    fn test_branching_tree_with_sibling_and_unrelated_stack()
    -> Result<(), Box<dyn std::error::Error>> {
        let url = |n: u64| format!("https://github.com/acme/webapp/pull/{n}");
        let pr = |number: u64, title: &str, head: &str, base: &str| PullRequest {
            number,
            title: title.to_string(),
            url: url(number),
            head_ref_name: head.to_string(),
            base_ref_name: base.to_string(),
            is_draft: false,
        };

        let prs = Vec::from([
            pr(101, "feat: base feature", "feature-a", "main"),
            pr(102, "feat: add API layer", "feature-b", "feature-a"),
            pr(103, "feat: add tests for API", "feature-c", "feature-b"),
            pr(104, "feat: docs for base", "feature-d", "feature-a"),
            // unrelated stack
            pr(105, "chore: CI setup", "feature-x", "main"),
            pr(106, "chore: add linting", "feature-y", "feature-x"),
        ]);

        // on feature-b: should show A's full subtree (B, C, D) but not X/Y
        let output = pr_stack::format_pr_stack_as_markdown(prs.clone(), "feature-b")?;
        assert_eq!(
            output,
            format!(
                "\
- [#101]({}) | feat: base feature
  - 👉🏻 **[#102]({})** | feat: add API layer 👈🏻
    - [#103]({}) | feat: add tests for API
  - [#104]({}) | feat: docs for base",
                url(101),
                url(102),
                url(103),
                url(104),
            )
        );

        // on feature-y: should show only the X/Y stack
        let output = pr_stack::format_pr_stack_as_markdown(prs.clone(), "feature-y")?;
        assert_eq!(
            output,
            format!(
                "\
- [#105]({}) | chore: CI setup
  - 👉🏻 **[#106]({})** | chore: add linting 👈🏻",
                url(105),
                url(106),
            )
        );

        // on feature-a: should show A's full subtree, not X/Y
        let output = pr_stack::format_pr_stack_as_markdown(prs, "feature-a")?;
        assert_eq!(
            output,
            format!(
                "\
- 👉🏻 **[#101]({})** | feat: base feature 👈🏻
  - [#102]({}) | feat: add API layer
    - [#103]({}) | feat: add tests for API
  - [#104]({}) | feat: docs for base",
                url(101),
                url(102),
                url(103),
                url(104),
            )
        );

        Ok(())
    }
}
