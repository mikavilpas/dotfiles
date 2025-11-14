use anyhow::Context;
use anyhow::Result;
use gix::Repository;
use std::collections::HashSet;

/// Return an iterator over the branch commits, stopping at wherever this branch diverged from any
/// other local branch.
pub(crate) fn stack_branch_iterator<S: AsRef<str> + std::fmt::Display>(
    repo: &Repository,
    branch: S,
) -> Result<gix::revision::Walk<'_>, anyhow::Error> {
    let start_commit = repo
        .try_find_reference(&format!("refs/heads/{branch}"))
        .with_context(|| format!("Failed to find reference for branch '{branch}'"))?
        .expect("Failed to get reference")
        .peel_to_commit()
        .with_context(|| format!("failed to peel_to_commit branch {branch}"))?;
    let branch_heads: HashSet<_> = repo
        .references()
        .context("failed to get references")?
        .local_branches()
        .context("failed to get local branches")?
        .try_fold(HashSet::new(), |mut set, branch_ref| -> anyhow::Result<_> {
            let branch = branch_ref.expect("Failed to get branch reference");
            let commit = repo
                .find_commit(branch.id())
                .with_context(|| format!("failed to find commit for branch {}", branch.id()))?;
            if commit.id != start_commit.id() {
                set.insert(commit.id);
            }

            Ok(set)
        })?;
    let revwalk = start_commit.ancestors().with_boundary(branch_heads).all()?;
    Ok(revwalk)
}
