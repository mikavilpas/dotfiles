use anyhow::Context;
use gix::Repository;
use std::process::{self};

use crate::commit_messages::get_commit_messages_on_current_branch;

use super::command_result::CommandResult;

pub struct GithubClient {
    repo: Repository,
}

impl GithubClient {
    pub fn new(repo: Repository) -> Self {
        GithubClient { repo }
    }

    pub fn edit_pr_interactive(&self) -> anyhow::Result<()> {
        let body = self.get_pr_contents()?;
        println!("Current PR body:\n{}", body.stdout);

        let lines = get_commit_messages_on_current_branch(&self.repo)?;
        let edit_result = self.edit_pr_body(&lines.join("\n"))?;
        println!("PR edited successfully. Result:\n{}", edit_result);

        todo!()
    }

    fn get_pr_contents(&self) -> anyhow::Result<CommandResult> {
        let mut command = process::Command::new("gh");
        command
            .current_dir(self.repo.path())
            .args(["pr", "view", "--json", "body", "--jq", ".body"]);
        let output = command.output().context("failed to run gh pr view")?;
        let result = CommandResult::try_from(output).context("error running gh pr view")?;

        Ok(result)
    }

    fn edit_pr_body(&self, new_body: &str) -> anyhow::Result<CommandResult> {
        let command = process::Command::new("gh")
            .current_dir(self.repo.path())
            .arg("pr")
            .arg("edit")
            .arg("--body")
            .arg(new_body)
            .output()
            .context("failed to run gh pr edit")?;

        let a = CommandResult::try_from(command).context("error running gh pr edit")?;
        Ok(a)
    }
}

#[cfg(test)]
mod tests {
    use test_utils::common::TestRepoBuilder;

    use super::*;

    #[test]

    fn test_get_pr_contents() -> Result<(), Box<dyn std::error::Error>> {
        let repo = TestRepoBuilder::new()?;
        repo.commit("initial commit")?;
        repo.commit("feat: commit 0")?;
        repo.commit("feat: commit 1")?;

        let client = GithubClient::new(repo.repo);
        let result = client.get_pr_contents()?;
        assert!(result.stdout.contains("feat: commit 0"));

        Ok(())
    }
}
