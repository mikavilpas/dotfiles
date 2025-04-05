use common::TestRepoBuilder;
use scripts::commit_messages::{
    get_commit_messages_between_commits, get_commit_messages_on_branch,
};

mod common;

#[test]
fn test_print_commit_messages_between_commits() -> Result<(), Box<dyn std::error::Error>> {
    let repo = TestRepoBuilder::new()?;
    repo.commit("initial commit")?;
    repo.commit("feat: commit 0")?;
    repo.commit("feat: commit 1")?;

    let lines = get_commit_messages_between_commits(&repo.repo, "HEAD", "HEAD~2")?;

    assert_eq!(lines, vec![
        //
        "# feat: commit 1",
        "",
        "# feat: commit 0",
        "",
    ]);

    Ok(())
}

#[test]
fn test_get_commit_messages_on_branch() -> Result<(), Box<dyn std::error::Error>> {
    let context = TestRepoBuilder::new()?;
    context.commit("initial commit")?;
    context.commit("feat: main commit 1")?;
    context.commit("feat: main commit 2")?;

    context.checkout("feature")?;

    context.commit("feat: feature commit 1")?;
    context.commit("feat: feature commit 2")?;
    context.commit("feat: feature commit 3")?;

    let lines = get_commit_messages_on_branch(&context.repo, "feature")?;

    assert_eq!(lines, vec![
        "# feat: feature commit 3",
        "",
        "# feat: feature commit 2",
        "",
        "# feat: feature commit 1",
        "",
    ]);

    Ok(())
}
