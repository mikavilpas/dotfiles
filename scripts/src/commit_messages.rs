use std::collections::HashSet;

use anyhow::{Context, Result};
use gix::{Commit, Repository};

pub fn get_commit_messages_between_commits(
    repo: &Repository,
    start_ref: &str,
    end_ref: &str,
) -> Result<Vec<String>, Box<dyn std::error::Error>> {
    let start = repo.rev_parse_single(start_ref)?;
    let end = repo.rev_parse_single(end_ref)?;

    // TODO test that the start commit is used, as opposed to using the head_commit
    let mut revwalk = repo.find_commit(start)?.ancestors().all()?;
    let mut result_lines = Vec::new();

    while let Some(commit) = revwalk.next().transpose()? {
        if commit.id == end {
            break;
        }
        let commit = repo.find_commit(commit.id)?;
        commit_as_markdown(&mut result_lines, &commit)?;
    }

    Ok(result_lines)
}

pub fn get_commit_messages_on_branch(
    repo: &Repository,
    branch: &str,
) -> anyhow::Result<Vec<String>, anyhow::Error> {
    let start_commit = repo
        .try_find_reference(&format!("refs/heads/{}", branch))
        .with_context(|| format!("Failed to find reference for branch '{}'", branch))?
        .expect("Failed to get reference")
        .peel_to_commit()
        .context("failed to peel_to_commit")?;

    let branch_heads: HashSet<_> = repo
        .references()
        .context("failed to get references")?
        .local_branches()
        .context("failed to get local branches")?
        .try_fold(HashSet::new(), |mut set, branch_ref| -> anyhow::Result<_> {
            let branch = branch_ref.expect("Failed to get branch reference");
            let commit = repo
                .find_commit(branch.id())
                .context("failed to find commit")?;
            if commit.id != start_commit.id() {
                set.insert(commit.id);
            }

            Ok(set)
        })?;

    let mut results = Vec::new();

    // TODO use the builtin revwalk filter
    let mut revwalk = start_commit.ancestors().all()?;
    while let Some(commit) = revwalk.next().transpose()? {
        if branch_heads.contains(&commit.id) {
            break;
        }
        let commit = repo
            .find_commit(commit.id)
            .context(format!("failed to find the commit {}", commit.id))?;
        commit_as_markdown(&mut results, &commit)?;
    }

    Ok(results)
}

fn commit_as_markdown(
    result_lines: &mut Vec<String>,
    commit: &Commit<'_>,
) -> Result<(), gix::object::commit::Error> {
    let first_line = commit.message()?.summary();
    let body = commit.message()?.body();

    result_lines.push(format!("# {}", first_line));
    result_lines.push("".to_string());

    if let Some(body_text) = body {
        result_lines.push(body_text.to_string());
        result_lines.push("".to_string());
    }

    Ok(())
}
