use anyhow::{Context, Result, bail};
use gix::Commit;
use gix::Repository;
use std::process::{self, Stdio};

use crate::commit_messages::my_commit::MyCommit;
mod my_commit;
mod stack_branch;

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
        let commit = create_commit(&commit)?;
        commit_as_markdown(&mut result_lines, commit);
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
    let mut results = Vec::new();
    let mut revwalk = stack_branch::stack_branch_iterator(repo, branch)?.peekable();
    while let Some(commit) = revwalk.next().transpose()? {
        let commit = repo
            .find_commit(commit.id)
            .with_context(|| format!("failed to find the commit {}", commit.id))?;
        let commit = create_commit(&commit)?;

        commit_as_markdown(&mut results, commit);

        if revwalk.peek().is_some() {
            results.push("".to_string()); // Add an empty line between commits
        }
    }
    results.push("".to_string());
    Ok(results)
}

fn create_commit(commit: &Commit<'_>) -> anyhow::Result<MyCommit> {
    let message = commit.message_raw_sloppy().to_string();
    let mut lines = message.lines();
    let first_line = lines
        .next()
        .ok_or_else(|| anyhow::anyhow!("commit message is empty"))?;
    let body = lines
        .skip_while(|l| l.trim().is_empty())
        .collect::<Vec<&str>>()
        .join("\n");
    Ok(MyCommit::new(first_line.to_string(), body))
}

fn commit_as_markdown(result_lines: &mut Vec<String>, commit: MyCommit) {
    result_lines.push(format!("# {}", commit.subject));

    if let Some(body) = &commit.body {
        result_lines.push("".to_string());
        body.split("\n").for_each(|line| {
            result_lines.push(line.to_string());
        });
    }
}

pub fn format_patch_with_instructions(repo: &Repository, commit_or_range: &str) -> Result<String> {
    let mut command = process::Command::new("git");
    let result = command
        .current_dir(repo.path())
        .args(["show", commit_or_range])
        .stdout(Stdio::piped());

    let output = match result.output() {
        Err(e) => {
            bail!("failed to run git show: {e}");
        }
        Ok(output) => {
            if !output.status.success() {
                bail!("git show failed with status: {}", output.status);
            }
            String::from_utf8(output.stdout)
                .map_err(|e| anyhow::anyhow!("failed to convert output to string: {e}"))?
        }
    };

    Ok(output)
}
