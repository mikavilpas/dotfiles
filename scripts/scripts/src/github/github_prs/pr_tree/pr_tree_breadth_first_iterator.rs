use super::super::PrNode;

use super::{PrNodeIndex, PrTree};

pub struct PrNodeBreadthFirstIterator<'a> {
    pr_tree: &'a PrTree,
    queue: Vec<PrNodeIndex>,
}

impl<'a> PrNodeBreadthFirstIterator<'a> {
    pub fn new(pr_tree: &'a PrTree) -> Self {
        Self {
            pr_tree,
            queue: pr_tree.root_indices.clone(),
        }
    }
}

pub struct PrStackNode<'a> {
    pub pr: &'a PrNode,
    pub index: PrNodeIndex,
}

pub struct Depth(pub usize);

impl<'a> Iterator for PrNodeBreadthFirstIterator<'a> {
    type Item = PrStackNode<'a>;

    fn next(&mut self) -> Option<Self::Item> {
        if let Some(node_idx) = self.queue.pop()
            && let Some(node) = self.pr_tree.get(node_idx)
        {
            // Add children to the queue
            for &child_idx in &node.children {
                self.queue.insert(0, child_idx); // Add to the end of the queue
            }
            return Some(PrStackNode {
                pr: node,
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
        number: u64,
        title: &str,
        head_ref_name: &str,
        base_ref_name: &str,
        children: Vec<PrNodeIndex>,
    ) -> PrNode {
        PrNode {
            pr: crate::github::github_prs::PullRequest {
                number,
                title: title.to_string(),
                url: "url".to_string(),
                head_ref_name: head_ref_name.to_string(),
                base_ref_name: base_ref_name.to_string(),
                is_draft: false,
            },
            children,
        }
    }

    #[test]
    fn test_breadth_first_iterator() {
        let tree = PrTree {
            nodes: vec![
                node(
                    1,
                    "PR 1",
                    "feature-1",
                    "main",
                    vec![PrNodeIndex(1), PrNodeIndex(2)],
                ),
                node(2, "PR 2", "feature-2", "feature-1", vec![]),
                node(3, "PR 3", "feature-3", "feature-1", vec![]),
            ],
            root_indices: vec![PrNodeIndex(0)],
        };

        let mut result = Vec::new();
        for node in PrNodeBreadthFirstIterator::new(&tree) {
            result.push(node.pr.pr.number);
        }

        assert_eq!(result, vec![1, 2, 3]);
    }
}
