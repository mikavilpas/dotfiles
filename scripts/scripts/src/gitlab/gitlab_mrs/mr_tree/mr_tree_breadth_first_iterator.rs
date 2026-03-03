use super::super::MrNode;

use super::{MrNodeIndex, MrTree};

pub struct MrNodeBreadthFirstIterator<'a> {
    mr_tree: &'a MrTree,
    queue: Vec<MrNodeIndex>,
}

impl<'a> MrNodeBreadthFirstIterator<'a> {
    pub fn new(mr_tree: &'a MrTree) -> Self {
        Self {
            mr_tree,
            queue: mr_tree.root_indices.clone(),
        }
    }
}

pub struct MrStackNode<'a> {
    pub mr: &'a MrNode,
    pub index: MrNodeIndex,
}

pub struct Depth(pub usize);

impl<'a> Iterator for MrNodeBreadthFirstIterator<'a> {
    type Item = MrStackNode<'a>;

    fn next(&mut self) -> Option<Self::Item> {
        if let Some(node_idx) = self.queue.pop()
            && let Some(node) = self.mr_tree.get(node_idx)
        {
            // Add children to the queue
            for &child_idx in &node.children {
                self.queue.insert(0, child_idx); // Add to the end of the queue
            }
            return Some(MrStackNode {
                mr: node,
                index: node_idx,
            });
        }
        None
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn node(
        iid: u64,
        title: &str,
        source_branch: &str,
        target_branch: &str,
        children: Vec<MrNodeIndex>,
    ) -> MrNode {
        MrNode {
            mr: crate::gitlab::gitlab_mrs::MergeRequest {
                iid,
                title: title.to_string(),
                web_url: "url".to_string(),
                source_branch: source_branch.to_string(),
                target_branch: target_branch.to_string(),
                draft: false,
            },
            children,
        }
    }

    #[test]
    fn test_breadth_first_iterator() {
        // node 0 (iid=1) has children [1, 2]
        let tree = MrTree {
            nodes: vec![
                node(
                    1,
                    "MR 1",
                    "feature-1",
                    "main",
                    vec![MrNodeIndex(1), MrNodeIndex(2)],
                ),
                node(2, "MR 2", "feature-2", "feature-1", vec![]),
                node(3, "MR 3", "feature-3", "feature-1", vec![]),
            ],
            root_indices: vec![MrNodeIndex(0)],
        };

        let mut result = Vec::new();
        for node in MrNodeBreadthFirstIterator::new(&tree) {
            result.push(node.mr.mr.iid);
        }

        assert_eq!(result, vec![1, 2, 3]);
    }
}
