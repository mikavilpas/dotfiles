use std::path::Path;

use anyhow::Result;
use scripts::project::path_to_project_file;
use test_utils::common::TestRepoBuilder;

#[test]
fn test_path_to_project_file_returns_file() -> Result<()> {
    let repo = TestRepoBuilder::new()?;

    let file = Path::new("file.txt");
    repo.create_file(file)?;

    let result = path_to_project_file(repo.path(), file)?;
    assert_eq!(result, "file.txt");

    Ok(())
}

#[test]
fn test_path_to_project_file_returns_dot() -> Result<()> {
    let repo = TestRepoBuilder::new()?;

    let file = Path::new(".");

    let result = path_to_project_file(repo.path(), file)?;
    assert_eq!(result, ".");

    Ok(())
}

#[test]
fn test_path_to_project_file_returns_file_in_dir() -> Result<()> {
    let repo = TestRepoBuilder::new()?;

    let file = Path::new("dir/file.txt");
    repo.create_file(file)?;

    let result = path_to_project_file(repo.path(), file)?;
    assert_eq!(result, "dir/file.txt");

    Ok(())
}

#[test]
fn test_path_to_project_file_returns_nonexisting_file() -> Result<()> {
    let repo = TestRepoBuilder::new()?;

    let file = Path::new("dir/file.txt");
    // do not create it

    let result = path_to_project_file(repo.path(), file)?;
    assert_eq!(result, "dir/file.txt");

    Ok(())
}

#[test]
fn test_path_to_project_file_returns_nonexisting_dir() -> Result<()> {
    let repo = TestRepoBuilder::new()?;

    let file = Path::new("dir/");
    // do not create it

    let result = path_to_project_file(repo.path(), file)?;
    assert_eq!(result, "dir");

    Ok(())
}

#[test]
fn test_path_to_project_file_with_nested_cwd() -> Result<()> {
    let repo = TestRepoBuilder::new()?;
    let file = Path::new("dir/file.txt");
    repo.create_file(file)?;

    let cwd = repo.path().join("dir"); // nested cwd
    let result = path_to_project_file(&cwd, Path::new("file.txt"))?;
    assert_eq!(result, "dir/file.txt");

    Ok(())
}

#[test]
fn test_path_to_project_file_accepts_full_path_in_another_repo() -> Result<()> {
    // rare edge case

    // Initialize two separate repos
    let repo1 = TestRepoBuilder::new()?;
    let repo2 = TestRepoBuilder::new()?;
    assert_ne!(
        repo1.path(),
        repo2.path(),
        "The two repositories should be different"
    );

    // Create a file inside repo2
    let file_in_repo2 = repo2.create_file(Path::new("external.txt"))?;
    assert!(file_in_repo2.is_absolute());

    // Try to resolve the file from repo2, but with cwd from repo1
    let result = path_to_project_file(repo1.path(), &file_in_repo2);

    // Should succeed, because the file path is absolute
    assert_eq!(
        result?,
        file_in_repo2
            .strip_prefix(repo2.path())
            .expect("prefix should be valid")
            .to_str()
            .expect("path should be valid utf-8")
    );

    Ok(())
}
