use std::collections::HashMap;

pub use super::MrNode;

use anyhow::Result;

use super::MergeRequest;

#[derive(Debug, Clone, Copy)]
pub struct MrNodeIndex(usize);

pub struct MrTree {
    pub(super) nodes: Vec<MrNode>,
    pub root_indices: Vec<MrNodeIndex>,
}

impl MrTree {
    pub fn get(&self, idx: MrNodeIndex) -> Option<&MrNode> {
        self.nodes.get(idx.0)
    }

    /// Walk up from the given node to find the root of its stack.
    /// Returns the root node's index (which may be `idx` itself if it's already a root).
    pub fn find_root_of(&self, idx: MrNodeIndex) -> MrNodeIndex {
        // Build a child -> parent map
        let mut parent_of: Vec<Option<MrNodeIndex>> = vec![None; self.nodes.len()];
        for (i, node) in self.nodes.iter().enumerate() {
            for &child_idx in &node.children {
                parent_of[child_idx.0] = Some(MrNodeIndex(i));
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

pub mod mr_tree_breadth_first_iterator;

pub enum TreeifyResult {
    Ok(MrTree),
    NoOpenMergeRequests,
}

/// Generate a flat "tree" structure of the given MRs based on source/target branch relationships.
/// Returns a tuple of (nodes, root_indices).
pub(crate) fn treeify_mrs(mrs: Vec<MergeRequest>) -> Result<TreeifyResult> {
    if mrs.is_empty() {
        return Ok(TreeifyResult::NoOpenMergeRequests);
    }
    let mut source_to_idx: HashMap<&str, usize> = HashMap::new();
    for (idx, mr) in mrs.iter().enumerate() {
        source_to_idx.insert(&mr.source_branch, idx);
    }
    let mut nodes: Vec<MrNode> = mrs
        .iter()
        .cloned()
        .map(|mr| MrNode {
            mr,
            children: vec![],
        })
        .collect();
    let mut has_parent = vec![false; mrs.len()];
    for (child_idx, mr) in mrs.iter().enumerate() {
        if let Some(&parent_idx) = source_to_idx.get(mr.target_branch.as_str()) {
            if let Some(parent_node) = nodes.get_mut(parent_idx) {
                parent_node.children.push(MrNodeIndex(child_idx));
            }
            if let Some(flag) = has_parent.get_mut(child_idx) {
                *flag = true;
            }
        }
    }
    let roots: Vec<MrNodeIndex> = has_parent
        .iter()
        .enumerate()
        .filter(|(_, has_parent)| !**has_parent)
        .map(|(i, _)| MrNodeIndex(i))
        .collect();
    let mut sorted_roots = roots;
    sorted_roots.sort_by_key(|&i| nodes.get(i.0).map(|n| n.mr.iid).unwrap_or(0));

    Ok(TreeifyResult::Ok(MrTree {
        nodes,
        root_indices: sorted_roots,
    }))
}
