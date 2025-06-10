use std::path::Path;

use scripts::commit_messages::{
    format_patch_with_instructions, get_commit_messages_between_commits,
    get_commit_messages_on_branch, get_commit_messages_on_current_branch,
};
use test_utils::common::TestRepoBuilder;

#[test]
fn test_print_commit_messages_between_commits() -> Result<(), Box<dyn std::error::Error>> {
    let repo = TestRepoBuilder::new()?;
    repo.commit("initial commit")?;
    repo.commit("feat: commit 0")?;
    repo.commit("feat: commit 1")?;

    let lines = get_commit_messages_between_commits(&repo.repo, "HEAD", "HEAD~2")?;

    assert_eq!(
        lines,
        vec![
            //
            "# feat: commit 1",
            "",
            "# feat: commit 0",
            "",
        ]
    );

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
    context.commit(
        &[
            "feat: feature commit 2",
            "",
            "This commit is on the feature branch.",
        ]
        .join("\n")
        .to_string(),
    )?;
    context.commit("feat: feature commit 3")?;

    let lines = get_commit_messages_on_branch(&context.repo, "feature")?;

    assert_eq!(
        lines,
        vec![
            "# feat: feature commit 3",
            "",
            "# feat: feature commit 2",
            "",
            "This commit is on the feature branch.",
            "",
            "# feat: feature commit 1",
            "",
        ]
    );

    Ok(())
}

#[test]
fn test_get_commit_messages_on_current_branch() -> Result<(), Box<dyn std::error::Error>> {
    let context = TestRepoBuilder::new()?;
    context.commit("initial commit")?;

    context.checkout("feature")?;

    context.commit("feat: feature commit 1")?;

    let lines = get_commit_messages_on_current_branch(&context.repo)?;

    assert_eq!(
        lines,
        vec![
            //
            "# feat: feature commit 1",
            "",
        ]
    );

    Ok(())
}

#[test]
fn test_include_codeblock_at_end() -> Result<(), Box<dyn std::error::Error>> {
    let context = TestRepoBuilder::new()?;
    context.commit("initial commit")?;

    context.checkout("feature")?;

    context.commit(
        &[
            "feat: update openapi from 1.4.3 to 1.4.5",
            "",
            "I verified that the test environment api does accept `phoneNumber` to be",
            "`undefined` by doing the following.",
            "",
            "```ts",
            "const response = await Service.patchApiData({",
            "  path: { id: 100 },",
            "})",
            "```",
        ]
        .join("\n"),
    )?;

    let lines = get_commit_messages_on_current_branch(&context.repo)?;

    assert_eq!(
        lines,
        vec![
            "# feat: update openapi from 1.4.3 to 1.4.5",
            "",
            "I verified that the test environment api does accept `phoneNumber` to be",
            "`undefined` by doing the following.",
            "",
            "```ts",
            "const response = await Service.patchApiData({",
            "  path: { id: 100 },",
            "})",
            "```",
            ""
        ],
    );

    Ok(())
}

#[test]
fn test_format_patch_with_instructions() -> Result<(), Box<dyn std::error::Error>> {
    let context = TestRepoBuilder::new()?;

    // create a commit and then store it as a patch
    context.commit("initial commit")?;
    context.checkout("feature")?;
    context.create_file(&context.path().join("README.md"))?;
    context.stage(Path::new("README.md"))?;
    context.commit("docs: add readme")?;

    // act
    let patch = format_patch_with_instructions(&context.repo, "HEAD")?;

    // assert
    context.switch("main")?;
    context.apply_patch(&patch)?;

    // the readme file should now exist in the main branch
    let readme_path = context.path().join("README.md");
    assert!(
        readme_path.exists(),
        "README.md should exist after applying patch"
    );

    Ok(())
}
