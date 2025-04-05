use gix::Repository;
use std::{
    path::{Path, PathBuf},
    process,
};
use tempfile::tempdir;

pub struct TestRepoBuilder {
    pub path: PathBuf,
    pub repo: Repository,
}

impl TestRepoBuilder {
    pub fn new() -> Result<TestRepoBuilder, Box<dyn std::error::Error>> {
        let tmpdir = tempdir()?;

        let repo = gix::init(tmpdir.path())?;
        run_git(tmpdir.path(), &["config", "user.name", "test"])?;
        run_git(tmpdir.path(), &[
            "config",
            "user.email",
            "test.user@example.com",
        ])?;

        Ok(Self {
            path: tmpdir.into_path(),
            repo,
        })
    }

    pub fn commit(&self, message: &str) -> Result<(), Box<dyn std::error::Error>> {
        run_git(
            self.path.as_path(),
            ["commit", "--allow-empty", "-m", message].as_ref(),
        )?;
        Ok(())
    }

    pub fn checkout(&self, branch: &str) -> Result<(), Box<dyn std::error::Error>> {
        run_git(self.path.as_path(), ["checkout", "-b", branch].as_ref())?;
        Ok(())
    }
}

/// Run `git` in `working_dir` with all provided `args`.
fn run_git(working_dir: &Path, args: &[&str]) -> std::io::Result<process::ExitStatus> {
    // from https://docs.rs/gix-testtools/latest/src/gix_testtools/lib.rs.html#174-179
    process::Command::new("git")
        .current_dir(working_dir)
        .args(args)
        .status()
        .map_err(|e| panic!("failed to run git: {}", e))
}
