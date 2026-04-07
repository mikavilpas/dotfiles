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

    /// Walk up from the given node to find the root of its stack.
    /// Returns the root node's index (which may be `idx` itself if it's already a root).
    pub fn find_root_of(&self, idx: PrNodeIndex) -> PrNodeIndex {
        // Build a child -> parent map
        let mut parent_of: Vec<Option<PrNodeIndex>> = vec![None; self.nodes.len()];
        for (i, node) in self.nodes.iter().enumerate() {
            for &child_idx in &node.children {
                parent_of[child_idx.0] = Some(PrNodeIndex(i));
            }
        }

        // Walk up from idx until we reach a node with no parent
        let mut current = idx;
        while let Some(parent) = parent_of[current.0] {
            current = parent;
        }
        current
    }
}

pub mod pr_tree_breadth_first_iterator;

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
