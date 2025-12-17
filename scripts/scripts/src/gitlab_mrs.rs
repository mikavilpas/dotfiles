use std::collections::HashMap;
use std::fs;
use std::io::{self, Read};
use std::path::Path;

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct MergeRequest {
    pub iid: u64,
    pub title: String,
    pub web_url: String,
    pub source_branch: String,
    pub target_branch: String,
    #[serde(default)]
    pub draft: bool,
}

/// Parse MRs from a JSON file (GitLab API format)
pub fn parse_mrs_from_file(path: &Path) -> Result<Vec<MergeRequest>> {
    let content = fs::read_to_string(path).context("failed to read MRs JSON file")?;
    parse_mrs_from_str(&content)
}

/// Parse MRs from stdin
pub fn parse_mrs_from_stdin() -> Result<Vec<MergeRequest>> {
    let mut content = String::new();
    io::stdin()
        .read_to_string(&mut content)
        .context("failed to read MRs from stdin")?;
    parse_mrs_from_str(&content)
}

/// Parse MRs from a JSON string
pub fn parse_mrs_from_str(content: &str) -> Result<Vec<MergeRequest>> {
    let mrs: Vec<MergeRequest> =
        serde_json::from_str(content).context("failed to parse MRs JSON")?;
    Ok(mrs)
}

/// A node in the MR tree
#[derive(Debug)]
struct MrNode {
    mr: MergeRequest,
    children: Vec<usize>,
}

/// Output format for MR summary
#[derive(Debug, Clone, Copy, Default)]
pub enum OutputFormat {
    /// Show MRs with links to GitLab
    #[default]
    Links,
    /// Show branch names instead of links
    Branches,
}

/// Build a tree structure from MRs based on source/target branch relationships
pub fn format_mrs_as_markdown(mrs: Vec<MergeRequest>, format: OutputFormat) -> String {
    if mrs.is_empty() {
        return "No open merge requests.".to_string();
    }

    // Build a map from source_branch -> MR index
    let mut source_to_idx: HashMap<&str, usize> = HashMap::new();
    for (idx, mr) in mrs.iter().enumerate() {
        source_to_idx.insert(&mr.source_branch, idx);
    }

    // Build adjacency: for each MR, find children (MRs whose target_branch == this MR's source_branch)
    let mut nodes: Vec<MrNode> = mrs
        .iter()
        .cloned()
        .map(|mr| MrNode {
            mr,
            children: vec![],
        })
        .collect();

    // Build parent->children relationships
    let mut has_parent = vec![false; mrs.len()];
    for (child_idx, mr) in mrs.iter().enumerate() {
        if let Some(&parent_idx) = source_to_idx.get(mr.target_branch.as_str()) {
            if let Some(parent_node) = nodes.get_mut(parent_idx) {
                parent_node.children.push(child_idx);
            }
            if let Some(flag) = has_parent.get_mut(child_idx) {
                *flag = true;
            }
        }
    }

    // Find root nodes (MRs without a parent in the set)
    let roots: Vec<usize> = has_parent
        .iter()
        .enumerate()
        .filter(|(_, has_parent)| !**has_parent)
        .map(|(i, _)| i)
        .collect();

    // Sort roots by iid ascending
    let mut sorted_roots = roots;
    sorted_roots.sort_by_key(|&i| nodes.get(i).map(|n| n.mr.iid).unwrap_or(0));

    // Generate markdown
    let mut output = String::from("");

    for &root_idx in &sorted_roots {
        format_mr_tree(&nodes, root_idx, 0, format, &mut output);
    }

    output.trim_end().to_string()
}

fn format_mr_tree(
    nodes: &[MrNode],
    idx: usize,
    depth: usize,
    format: OutputFormat,
    output: &mut String,
) {
    let Some(node) = nodes.get(idx) else {
        return;
    };
    let mr = &node.mr;

    // Indentation
    let indent = "  ".repeat(depth);

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

    match format {
        OutputFormat::Links => {
            output.push_str(&format!(
                "{}- [!{}]({}) {}\n",
                indent, mr.iid, mr.web_url, title_display
            ));
        }
        OutputFormat::Branches => {
            // Use OSC 8 hyperlink escape sequence for clickable links in modern terminals
            // Format: \x1b]8;;URL\x1b\\TEXT\x1b]8;;\x1b\\
            //
            // https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
            output.push_str(&format!(
                "{}- `\x1b]8;;{}\x1b\\{}\x1b]8;;\x1b\\` {}\n",
                indent, mr.web_url, mr.source_branch, title_display
            ));
        }
    }

    // Sort children by iid ascending and recurse
    let mut sorted_children = node.children.clone();
    sorted_children.sort_by_key(|&i| nodes.get(i).map(|n| n.mr.iid).unwrap_or(0));

    for &child_idx in &sorted_children {
        format_mr_tree(nodes, child_idx, depth + 1, format, output);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_simple_mr() {
        let json = r#"[{
            "iid": 101,
            "title": "feat: add user authentication",
            "web_url": "https://gitlab.example.com/acme/webapp/-/merge_requests/101",
            "source_branch": "feature-auth",
            "target_branch": "main",
            "draft": false
        }]"#;

        let mrs: Vec<MergeRequest> = serde_json::from_str(json).unwrap();
        assert_eq!(mrs.len(), 1);
        assert_eq!(mrs.first().map(|m| m.iid), Some(101));
        assert_eq!(
            mrs.first().map(|m| m.title.as_str()),
            Some("feat: add user authentication")
        );
        assert!(!mrs.first().is_some_and(|m| m.draft));
    }

    #[test]
    fn test_parse_draft_mr() {
        let json = r#"[{
            "iid": 102,
            "title": "Draft: refactor: migrate to new API client",
            "web_url": "https://gitlab.example.com/acme/webapp/-/merge_requests/102",
            "source_branch": "refactor-api",
            "target_branch": "main",
            "draft": true
        }]"#;

        let mrs: Vec<MergeRequest> = serde_json::from_str(json).unwrap();
        assert_eq!(mrs.len(), 1);
        assert!(mrs.first().is_some_and(|m| m.draft));
    }

    #[test]
    fn test_format_single_mr() {
        let mrs = vec![MergeRequest {
            iid: 101,
            title: "feat: add dark mode support".to_string(),
            web_url: "https://gitlab.example.com/acme/webapp/-/merge_requests/101".to_string(),
            source_branch: "feature-dark-mode".to_string(),
            target_branch: "main".to_string(),
            draft: false,
        }];

        let output = format_mrs_as_markdown(mrs, OutputFormat::Links);
        assert!(output.contains("[!101]"));
        assert!(output.contains("feat: add dark mode support"));
    }

    #[test]
    fn test_format_draft_mr() {
        let mrs = vec![MergeRequest {
            iid: 102,
            title: "Draft: experimental caching layer".to_string(),
            web_url: "https://gitlab.example.com/acme/webapp/-/merge_requests/102".to_string(),
            source_branch: "feature-cache".to_string(),
            target_branch: "main".to_string(),
            draft: true,
        }];

        let output = format_mrs_as_markdown(mrs, OutputFormat::Links);
        assert!(output.contains("**Draft:** experimental caching layer"));
    }

    #[test]
    fn test_format_nested_mrs() {
        // Create a chain: MR 101 -> MR 102 (102's target = 101's source)
        let mrs = vec![
            MergeRequest {
                iid: 101,
                title: "feat: base feature".to_string(),
                web_url: "https://gitlab.example.com/acme/webapp/-/merge_requests/101".to_string(),
                source_branch: "feature-101".to_string(),
                target_branch: "main".to_string(),
                draft: false,
            },
            MergeRequest {
                iid: 102,
                title: "feat: dependent feature".to_string(),
                web_url: "https://gitlab.example.com/acme/webapp/-/merge_requests/102".to_string(),
                source_branch: "feature-102".to_string(),
                target_branch: "feature-101".to_string(), // targets 101's source
                draft: false,
            },
        ];

        let output = format_mrs_as_markdown(mrs, OutputFormat::Links);
        // 102 should be indented under 101
        assert!(output.contains("- [!101]"));
        assert!(output.contains("  - [!102]"));
    }

    #[test]
    fn test_format_branches() {
        let mrs = vec![
            MergeRequest {
                iid: 101,
                title: "feat: base feature".to_string(),
                web_url: "https://gitlab.example.com/acme/webapp/-/merge_requests/101".to_string(),
                source_branch: "feature-101".to_string(),
                target_branch: "main".to_string(),
                draft: false,
            },
            MergeRequest {
                iid: 102,
                title: "Draft: dependent feature".to_string(),
                web_url: "https://gitlab.example.com/acme/webapp/-/merge_requests/102".to_string(),
                source_branch: "feature-102".to_string(),
                target_branch: "feature-101".to_string(),
                draft: true,
            },
        ];

        let output = format_mrs_as_markdown(mrs, OutputFormat::Branches);
        // Contains branch names with OSC 8 hyperlinks
        assert!(output.contains("feature-101"));
        assert!(output.contains("feat: base feature"));
        assert!(output.contains("feature-102"));
        assert!(output.contains("**Draft:** dependent feature"));
        // Should not contain markdown-style links
        assert!(!output.contains("[!"));
    }
}
