use super::create_commit;
use crate::commit_messages::{
    CreateCommitResult,
    my_commit::MyCommit,
    stack_branch::{self, commit_range_iterator},
};
use anyhow::Context;
use gix::Repository;

pub fn commits_with_fixups_on_branch<S: AsRef<str> + std::fmt::Display>(
    repo: &Repository,
    branch: S,
) -> anyhow::Result<Vec<MyCommit>> {
    // Collect the commits on this branch
    let commits: Vec<Option<MyCommit>> = {
        let mut revwalk = stack_branch::stack_branch_iterator(repo, branch)?.peekable();
        let mut result = Vec::new();
        while let Some(commit) = revwalk.next().transpose()? {
            let commit = repo
                .find_commit(commit.id)
                .with_context(|| format!("failed to find the commit {}", commit.id))?;
            if let CreateCommitResult::Commit(my_commit) = create_commit(&commit)? {
                result.push(Some(my_commit))
            }
        }
        result.reverse();
        result
    };

    combine_fixups_with_commits(commits)
}

pub fn commits_with_fixups<S: AsRef<str> + std::fmt::Display>(
    repo: &Repository,
    start_ref: S,
    end_ref: S,
) -> anyhow::Result<Vec<MyCommit>> {
    // Collect the commits on this branch
    let mut result = Vec::new();
    let commits: Vec<Option<MyCommit>> = {
        let mut revwalk = commit_range_iterator(repo, start_ref, end_ref)?;
        while let Some(commit) = revwalk.next().transpose()? {
            let commit = repo
                .find_commit(commit.id)
                .with_context(|| format!("failed to find the commit {}", commit.id))?;

            if let CreateCommitResult::Commit(my_commit) = create_commit(&commit)? {
                result.push(Some(my_commit))
            }
        }
        result.reverse();
        result
    };

    combine_fixups_with_commits(commits)
}

fn combine_fixups_with_commits(
    mut commits: Vec<Option<MyCommit>>,
) -> Result<Vec<MyCommit>, anyhow::Error> {
    let len = commits.len();
    for i in (0..len).rev() {
        // Split so `slot` and `before` are disjoint mutable slices
        let (before, slot) = commits.split_at_mut(i);

        #[allow(clippy::indexing_slicing)]
        let slot = &mut slot[0];

        let is_fixup = slot.as_ref().map(|c| c.is_fixup()).unwrap_or(false);
        if !is_fixup {
            continue;
        }

        // safe because is_fixup implies slot.is_some()
        let commit = slot.take().unwrap();

        // Find base commit in earlier commits
        let base_slot = before.iter_mut().rev().find(|maybe_base| {
            maybe_base
                .as_ref()
                .map(|c| commit.is_fixup_for(c))
                .unwrap_or(false)
        });

        match base_slot {
            None => {
                eprintln!("warn: no base commit found for fixup at index {i}");
                *slot = Some(commit); // put it back
            }
            Some(base_slot) => {
                let mut base_commit = base_slot.take().expect("base commit must exist");
                base_commit.fixups.push(commit.into());
                *base_slot = Some(base_commit);
            }
        }
    }

    Ok(commits.into_iter().flatten().collect())
}
