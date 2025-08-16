use std::{
    collections::HashSet,
    process::{self, Stdio},
};

use anyhow::{Context, Result, bail};
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
        result_lines.push("".to_string()); // Add an empty line between commits
    }

    Ok(result_lines)
}

pub fn get_commit_messages_on_current_branch(
    repo: &Repository,
) -> anyhow::Result<Vec<String>, anyhow::Error> {
    let current_branch = get_current_branch_name(repo)?;
    get_commit_messages_on_branch(repo, &current_branch)
        .with_context(|| format!("failed to get commit messages on branch {current_branch}"))
}

pub fn get_current_branch_name(repo: &Repository) -> anyhow::Result<String> {
    let head = repo.head().with_context(|| {
        format!(
            "failed to get current branch for repo {}",
            repo.path().display()
        )
    })?;
    let a = match head.kind {
        gix::head::Kind::Symbolic(reference) => reference.name.shorten().to_string(),
        _ => bail!("current HEAD is not a symbolic reference"),
    };
    Ok(a)
}

pub fn get_commit_messages_on_branch<S: AsRef<str> + std::fmt::Display>(
    repo: &Repository,
    branch: S,
) -> anyhow::Result<Vec<String>, anyhow::Error> {
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

    let mut results = Vec::new();

    let mut revwalk = start_commit.ancestors().with_boundary(branch_heads).all()?;
    while let Some(commit) = revwalk.next().transpose()? {
        let commit = repo
            .find_commit(commit.id)
            .with_context(|| format!("failed to find the commit {}", commit.id))?;
        commit_as_markdown(&mut results, &commit)?;
        results.push("".to_string()); // Add an empty line between commits
    }

    Ok(results)
}

fn commit_as_markdown(
    result_lines: &mut Vec<String>,
    commit: &Commit<'_>,
) -> Result<(), gix::object::commit::Error> {
    let message = commit.message_raw_sloppy().to_string();
    let mut lines = message.lines();
    if let Some(first_line) = lines.next() {
        result_lines.push(format!("# {first_line}"));

        lines.for_each(|line| {
            result_lines.push(line.to_string());
        });
    }

    Ok(())
}

pub fn format_patch_with_instructions(repo: &Repository, commit_or_range: &str) -> Result<String> {
    let mut command = process::Command::new("git");
    let result = command
        .current_dir(repo.path())
        .args(["show", commit_or_range])
        .stdout(Stdio::piped());

    let output = match result.output() {
        Err(e) => {
            bail!("failed to run git show: {}", e);
        }
        Ok(output) => {
            if !output.status.success() {
                bail!("git show failed with status: {}", output.status);
            }
            String::from_utf8(output.stdout)
                .map_err(|e| anyhow::anyhow!("failed to convert output to string: {}", e))?
        }
    };

    Ok(output)
}
