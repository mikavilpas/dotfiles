use anyhow::Result;
use gix::Repository;
use std::{
    path::{Path, PathBuf},
    process,
};
use tempfile::{TempDir, tempdir};

pub struct TestRepoBuilder {
    tmpdir: TempDir,
    pub repo: Repository,
}

impl TestRepoBuilder {
    pub fn new() -> Result<TestRepoBuilder> {
        let tmpdir = tempdir()?;
        let dir = tmpdir.path().to_path_buf();

        let repo = gix::init(&dir)?;

        run_git(&dir, &["config", "user.name", "test"])?;
        run_git(&dir, &["config", "user.email", "test.user@example.com"])?;

        Ok(Self { tmpdir, repo })
    }

    pub fn commit(&self, message: &str) -> Result<()> {
        run_git(
            self.path(),
            ["commit", "--allow-empty", "-m", message].as_ref(),
        )?;
        Ok(())
    }

    pub fn checkout(&self, branch: &str) -> Result<()> {
        run_git(self.path(), ["checkout", "-b", branch].as_ref())?;
        Ok(())
    }

    pub fn create_file(&self, file: &Path) -> Result<PathBuf> {
        let file_path = self.path().join(file);
        std::fs::create_dir_all(file_path.parent().unwrap())?;
        std::fs::write(&file_path, "test")?;
        Ok(file_path)
    }

    pub fn path(&self) -> &std::path::Path {
        self.tmpdir.path()
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
