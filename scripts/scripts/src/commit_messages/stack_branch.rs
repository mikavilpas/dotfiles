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
    let start_commit = get_current_commit(repo, branch)?;
    let branch_heads = get_branch_heads(repo, &start_commit)?;
    let revwalk = start_commit.ancestors().with_boundary(branch_heads).all()?;
    Ok(revwalk)
}

pub(crate) fn commit_range_iterator<S: AsRef<str> + std::fmt::Display>(
    repo: &Repository,
    start_ref: S,
    end_ref: S,
) -> Result<gix::revision::Walk<'_>, anyhow::Error> {
    let start_commit = repo
        .rev_parse_single(start_ref.as_ref())
        .with_context(|| format!("failed to rev-parse start ref '{start_ref}'"))?;
    let end_commit = repo
        .rev_parse_single(end_ref.as_ref())
        .with_context(|| format!("failed to rev-parse end ref '{end_ref}'"))?;
    let start_commit = repo
        .find_commit(start_commit)
        .with_context(|| format!("failed to find start commit '{start_ref}'"))?;
    let revwalk = start_commit.ancestors().with_boundary([end_commit]).all()?;
    Ok(revwalk)
}

fn get_current_commit<S: AsRef<str> + std::fmt::Display>(
    repo: &Repository,
    branch: S,
) -> Result<gix::Commit<'_>, anyhow::Error> {
    let start_commit = repo
        .try_find_reference(&format!("refs/heads/{branch}"))
        .with_context(|| format!("Failed to find reference for branch '{branch}'"))?
        .expect("Failed to get reference")
        .peel_to_commit()
        .with_context(|| format!("failed to peel_to_commit branch {branch}"))?;
    Ok(start_commit)
}

fn get_branch_heads(
    repo: &Repository,
    start_commit: &gix::Commit<'_>,
) -> Result<HashSet<gix::ObjectId>, anyhow::Error> {
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
    Ok(branch_heads)
}
