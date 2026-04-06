use std::fs;
use std::io::{self, Read};
use std::path::Path;

use anyhow::{Context, Result, bail};
use serde::{Deserialize, Serialize};

pub mod pr_stack;
mod pr_tree;

/// A GitHub pull request, matching the JSON output of `gh pr list --json number,title,url,headRefName,baseRefName,isDraft`
#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PullRequest {
    pub number: u64,
    pub title: String,
    pub url: String,
    pub head_ref_name: String,
    pub base_ref_name: String,
    #[serde(default)]
    pub is_draft: bool,
}

pub fn parse_github_prs_from_file_or_stdin(file: std::path::PathBuf) -> Vec<PullRequest> {
    if file.as_os_str() == "-" {
        parse_prs_from_stdin().unwrap_or_else(|e| panic!("failed to parse PRs: {e}"))
    } else {
        let cwd = std::env::current_dir().expect("failed to get current directory");
        let path = if file.is_absolute() {
            file
        } else {
            cwd.join(file)
        };
        parse_prs_from_file(&path).unwrap_or_else(|e| panic!("failed to parse PRs: {e}"))
    }
}

/// Parse PRs from a JSON file (GitHub API format)
pub fn parse_prs_from_file(path: &Path) -> Result<Vec<PullRequest>> {
    let content = fs::read_to_string(path).context("failed to read PRs JSON file")?;
    parse_prs_from_str(&content)
}

/// Parse PRs from stdin
pub fn parse_prs_from_stdin() -> Result<Vec<PullRequest>> {
    let mut content = String::new();
    io::stdin()
        .read_to_string(&mut content)
        .context("failed to read PRs from stdin")?;
    parse_prs_from_str(&content)
}

/// Parse PRs from a JSON string
pub fn parse_prs_from_str(content: &str) -> Result<Vec<PullRequest>> {
    let prs: Vec<PullRequest> =
        serde_json::from_str(content).context("failed to parse PRs JSON")?;
    Ok(prs)
}

/// A node in the PR tree
#[derive(Debug)]
pub struct PrNode {
    pr: PullRequest,
    children: Vec<pr_tree::PrNodeIndex>,
}

/// Output format for PR summary
#[derive(Debug, Clone, Copy, Default)]
pub enum OutputFormat {
    /// Show PRs with links to GitHub
    #[default]
    Links,
    /// Show branch names instead of links
    Branches,
}

/// Build a markdown tree structure from PRs
pub fn format_prs_as_markdown(prs: Vec<PullRequest>, format: OutputFormat) -> Result<String> {
    let pr_tree = match pr_tree::treeify_prs(prs)? {
        pr_tree::TreeifyResult::Ok(pr_tree) => pr_tree,
        pr_tree::TreeifyResult::NoOpenPullRequests => bail!("No open pull requests."),
    };

    let mut output = String::from("");

    for &root_idx in &pr_tree.root_indices {
        format_pr_tree(&pr_tree, root_idx, 0, format, &mut output);
    }

    Ok(output.trim_end().to_string())
}

fn format_pr_tree(
    tree: &pr_tree::PrTree,
    idx: pr_tree::PrNodeIndex,
    depth: usize,
    format: OutputFormat,
    output: &mut String,
) {
    let Some(node) = tree.get(idx) else {
        return;
    };
    let pr = &node.pr;

    let indent = "  ".repeat(depth);

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

    match format {
        OutputFormat::Links => {
            output.push_str(&format!(
                "{}- [#{}]({}) {}\n",
                indent, pr.number, pr.url, title_display
            ));
        }
        OutputFormat::Branches => {
            // Use OSC 8 hyperlink escape sequence for clickable links in modern terminals
            use crate::style::*;
            output.push_str(&format!(
                "{indent}- `{OSC8_START}{url}{OSC8_MID}{branch}{OSC8_END}` {title_display}\n",
                url = pr.url,
                branch = pr.head_ref_name,
            ));
        }
    }

    let mut sorted_children = node.children.clone();
    sorted_children.sort_by_key(|&i| tree.get(i).map(|n| n.pr.number).unwrap_or(0));

    for &child_idx in &sorted_children {
        format_pr_tree(tree, child_idx, depth + 1, format, output);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_simple_pr() {
        let json = r#"[{
            "number": 101,
            "title": "feat: add user authentication",
            "url": "https://github.com/acme/webapp/pull/101",
            "headRefName": "feature-auth",
            "baseRefName": "main",
            "isDraft": false
        }]"#;

        let prs: Vec<PullRequest> = serde_json::from_str(json).unwrap();
        assert_eq!(prs.len(), 1);
        assert_eq!(prs.first().map(|p| p.number), Some(101));
        assert_eq!(
            prs.first().map(|p| p.title.as_str()),
            Some("feat: add user authentication")
        );
        assert!(!prs.first().is_some_and(|p| p.is_draft));
    }

    #[test]
    fn test_parse_draft_pr() {
        let json = r#"[{
            "number": 102,
            "title": "Draft: refactor: migrate to new API client",
            "url": "https://github.com/acme/webapp/pull/102",
            "headRefName": "refactor-api",
            "baseRefName": "main",
            "isDraft": true
        }]"#;

        let prs: Vec<PullRequest> = serde_json::from_str(json).unwrap();
        assert_eq!(prs.len(), 1);
        assert!(prs.first().is_some_and(|p| p.is_draft));
    }

    #[test]
    fn test_format_single_pr() -> Result<(), Box<dyn std::error::Error>> {
        let prs = vec![PullRequest {
            number: 101,
            title: "feat: add dark mode support".to_string(),
            url: "https://github.com/acme/webapp/pull/101".to_string(),
            head_ref_name: "feature-dark-mode".to_string(),
            base_ref_name: "main".to_string(),
            is_draft: false,
        }];

        let output = format_prs_as_markdown(prs, OutputFormat::Links)?;
        assert!(output.contains("[#101]"));
        assert!(output.contains("feat: add dark mode support"));
        Ok(())
    }

    #[test]
    fn test_format_draft_pr() -> Result<(), Box<dyn std::error::Error>> {
        let prs = vec![PullRequest {
            number: 102,
            title: "Draft: experimental caching layer".to_string(),
            url: "https://github.com/acme/webapp/pull/102".to_string(),
            head_ref_name: "feature-cache".to_string(),
            base_ref_name: "main".to_string(),
            is_draft: true,
        }];

        let output = format_prs_as_markdown(prs, OutputFormat::Links)?;
        assert!(output.contains("**Draft:** experimental caching layer"));
        Ok(())
    }

    #[test]
    fn test_format_nested_prs() -> Result<(), Box<dyn std::error::Error>> {
        let prs = vec![
            PullRequest {
                number: 101,
                title: "feat: base feature".to_string(),
                url: "https://github.com/acme/webapp/pull/101".to_string(),
                head_ref_name: "feature-101".to_string(),
                base_ref_name: "main".to_string(),
                is_draft: false,
            },
            PullRequest {
                number: 102,
                title: "feat: dependent feature".to_string(),
                url: "https://github.com/acme/webapp/pull/102".to_string(),
                head_ref_name: "feature-102".to_string(),
                base_ref_name: "feature-101".to_string(),
                is_draft: false,
            },
        ];

        let output = format_prs_as_markdown(prs, OutputFormat::Links)?;
        assert!(output.contains("- [#101]"));
        assert!(output.contains("  - [#102]"));
        Ok(())
    }

    #[test]
    fn test_format_branches() -> Result<(), Box<dyn std::error::Error>> {
        let prs = vec![
            PullRequest {
                number: 101,
                title: "feat: base feature".to_string(),
                url: "https://github.com/acme/webapp/pull/101".to_string(),
                head_ref_name: "feature-101".to_string(),
                base_ref_name: "main".to_string(),
                is_draft: false,
            },
            PullRequest {
                number: 102,
                title: "Draft: dependent feature".to_string(),
                url: "https://github.com/acme/webapp/pull/102".to_string(),
                head_ref_name: "feature-102".to_string(),
                base_ref_name: "feature-101".to_string(),
                is_draft: true,
            },
        ];

        let output = format_prs_as_markdown(prs, OutputFormat::Branches)?;
        assert!(output.contains("feature-101"));
        assert!(output.contains("feat: base feature"));
        assert!(output.contains("feature-102"));
        assert!(output.contains("**Draft:** dependent feature"));
        // Should not contain markdown-style links
        assert!(!output.contains("[#"));
        Ok(())
    }
}
