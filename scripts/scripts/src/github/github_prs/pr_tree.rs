use std::collections::HashMap;

pub use super::PrNode;

use anyhow::Result;

use super::PullRequest;

#[derive(Debug, Clone, Copy)]
pub struct PrNodeIndex(pub usize);

pub struct PrTree {
    pub(super) nodes: Vec<PrNode>,
    pub root_indices: Vec<PrNodeIndex>,
}

impl PrTree {
    pub fn get(&self, idx: PrNodeIndex) -> Option<&PrNode> {
        self.nodes.get(idx.0)
    }
}

pub enum TreeifyResult {
    Ok(PrTree),
    NoOpenPullRequests,
}

/// Generate a flat "tree" structure of the given PRs based on head/base branch relationships.
pub(crate) fn treeify_prs(prs: Vec<PullRequest>) -> Result<TreeifyResult> {
    if prs.is_empty() {
        return Ok(TreeifyResult::NoOpenPullRequests);
    }
    let mut head_to_idx: HashMap<&str, usize> = HashMap::new();
    for (idx, pr) in prs.iter().enumerate() {
        // If there is a PR from a fork-main->main, ignore it.
        //
        // These are never a legitimate parent in a stack. In practice they appear when a fork opens
        // a PR from its own default branch: `gh pr list` reports the head as the bare branch name
        // (e.g. `main`) with no owner qualifier, so a fork's `main` -> `main` PR collides with our
        // own `main`.
        if pr.head_ref_name == pr.base_ref_name {
            continue;
        }
        head_to_idx.insert(&pr.head_ref_name, idx);
    }
    let mut nodes: Vec<PrNode> = prs
        .iter()
        .cloned()
        .map(|pr| PrNode {
            pr,
            children: vec![],
        })
        .collect();
    let mut has_parent = vec![false; prs.len()];
    for (child_idx, pr) in prs.iter().enumerate() {
        if let Some(&parent_idx) = head_to_idx.get(pr.base_ref_name.as_str()) {
            if let Some(parent_node) = nodes.get_mut(parent_idx) {
                parent_node.children.push(PrNodeIndex(child_idx));
            }
            if let Some(flag) = has_parent.get_mut(child_idx) {
                *flag = true;
            }
        }
    }
    let roots: Vec<PrNodeIndex> = has_parent
        .iter()
        .enumerate()
        .filter(|(_, has_parent)| !**has_parent)
        .map(|(i, _)| PrNodeIndex(i))
        .collect();
    let mut sorted_roots = roots;
    sorted_roots.sort_by_key(|&i| nodes.get(i.0).map(|n| n.pr.number).unwrap_or(0));

    Ok(TreeifyResult::Ok(PrTree {
        nodes,
        root_indices: sorted_roots,
    }))
}
