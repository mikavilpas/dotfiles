use assert_cmd::cargo;
use pretty_assertions::assert_eq;
use scripts::commit_messages::{
    fixup_commits::commits_with_fixups_on_branch,
    get_commit_messages_on_current_branch,
    my_commit::{FixupCommit, MyCommit},
};
use std::path::Path;
use test_utils::common::TestRepoBuilder;

#[test]
fn test_mika_provides_help() {
    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd.args(["--help"]).assert();
    let output = String::from_utf8(assert.success().get_output().stdout.clone())
        .expect("failed to convert stdout to string");

    insta::assert_snapshot!(output);
}

#[test]
fn test_mika_provides_help_for_unknown_command() {
    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd.args(["missing_cmd"]).assert();
    let output = String::from_utf8(assert.failure().get_output().stderr.clone())
        .expect("failed to convert stderr to string");

    insta::assert_snapshot!(output);
}

#[test]
fn test_mika_shows_subcommand_help_for_incorrect_args() {
    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd.args(["mr-stack-summary"]).assert();
    let output = String::from_utf8(assert.failure().get_output().stderr.clone())
        .expect("failed to convert stderr to string");

    insta::assert_snapshot!(output);
}

#[test]
fn test_summary() -> Result<(), Box<dyn std::error::Error>> {
    let repo = TestRepoBuilder::new()?;
    repo.commit("initial commit")?;

    let include_commits = [
        "feat: commit 0",
        "feat: commit 1",
        "fixup! feat: commit 0\n\nA fixup commit message.",
        "fixup! feat: commit 1\n\nAddress a review comment about formatting.",
        "fixup! feat: commit 0\n\nFix remaining bugs.",
    ];
    let ignore_commits = ["feat: commit 2"]; // should be ignored in the summary
    for msg in include_commits.iter().chain(ignore_commits.iter()) {
        repo.commit(msg)?;
    }

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .current_dir(repo.path())
        .args([
            // to keep the test maintainable, we specify the range of commits to include
            // dynamically based on the number of commits we created above.
            "summary",
            "--from",
            &format!("HEAD~{}", ignore_commits.len()),
            "--to",
            &format!("HEAD~{}", ignore_commits.len() + include_commits.len()),
        ])
        .assert();

    let output = String::from_utf8(assert.get_output().stdout.clone())
        .expect("failed to convert stdout to string");
    assert_eq!(
        output,
        [
            //
            "# feat: commit 1",
            "",
            "**Fixups:**",
            "  - Address a review comment about formatting.",
            "",
            "# feat: commit 0",
            "",
            "**Fixups:**",
            "  - Fix remaining bugs.",
            "  - A fixup commit message.",
            "",
            "",
        ]
        .join("\n"),
    );

    Ok(())
}

#[test]
fn test_branch_summary() -> Result<(), Box<dyn std::error::Error>> {
    let context = TestRepoBuilder::new()?;
    // create some commits on a different branch. These should not appear in the summary.
    context.commit("initial commit")?;
    context.commit("feat: main commit 1")?;
    context.commit("feat: main commit 2")?;

    context.checkout_b("feature")?;

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
    context.commit("fixup! feat: feature commit 1")?;
    context.commit(
        &[
            "fixup! feat: feature commit 1",
            "",
            "Address a review comment suggesting a refactoring.",
        ]
        .join("\n")
        .to_string(),
    )?;
    // add an orphan fixup commit that has no associated commit. It should be rendered as a normal
    // commit.
    context.commit("fixup! feat: orphan fixup commit")?;

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .current_dir(context.path())
        .args(["branch-summary", "--branch", "feature"])
        .assert();

    let stdout = String::from_utf8(assert.get_output().stdout.clone())
        .expect("failed to convert stdout to string");
    assert_eq!(
        stdout,
        [
            "# fixup! feat: orphan fixup commit",
            "",
            "# feat: feature commit 3",
            "",
            "# feat: feature commit 2",
            "",
            "This commit is on the feature branch.",
            "",
            "# feat: feature commit 1",
            "",
            "**Fixups:**",
            "  - Address a review comment suggesting a refactoring.",
            "",
            "",
        ]
        .join("\n"),
    );

    Ok(())
}

#[test]
fn test_get_commit_messages_on_current_branch() -> Result<(), Box<dyn std::error::Error>> {
    let context = TestRepoBuilder::new()?;
    context.commit("initial commit")?;

    context.checkout_b("feature")?;

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

    context.checkout_b("feature")?;

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
    context.checkout_b("feature")?;
    context.create_file(&context.path().join("README.md"))?;
    context.stage(Path::new("README.md"))?;
    context.commit("docs: add readme")?;

    // act
    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .current_dir(context.repo.path())
        .args(["share-patch", "--commit", "HEAD"])
        .assert();

    // assert
    let stdout = assert.success().get_output().stdout.clone();
    let patch = str::from_utf8(&stdout)
        .expect("failed to convert stdout to string")
        .to_string();

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

#[test]
fn test_fixups_are_grouped_over_another_commit() -> Result<(), Box<dyn std::error::Error>> {
    let repo = TestRepoBuilder::new()?;

    repo.commit("feat: my-feature")?;
    repo.commit("fixup! feat: my-feature")?;
    repo.commit("feat: another-feature")?;
    repo.commit("fixup! feat: my-feature")?;
    repo.commit("fixup! feat: another-feature")?;

    // these should be ignored as they are not useful in the report
    repo.commit("squash! feat: another-feature")?;
    repo.commit("amend! feat: another-feature")?;
    repo.commit("reword! feat: another-feature")?;

    // act
    let result = commits_with_fixups_on_branch(&repo.repo, "main")?;

    // assert
    assert_eq!(
        result,
        [
            MyCommit {
                subject: "feat: my-feature".to_string(),
                body: None,
                fixups: vec![
                    FixupCommit {
                        subject: "fixup! feat: my-feature".to_string(),
                        body: None,
                    },
                    FixupCommit {
                        subject: "fixup! feat: my-feature".to_string(),
                        body: None,
                    },
                ],
            },
            MyCommit {
                subject: "feat: another-feature".to_string(),
                body: None,
                fixups: vec![FixupCommit {
                    subject: "fixup! feat: another-feature".to_string(),
                    body: None,
                },],
            }
        ]
    );

    Ok(())
}

#[test]
fn test_fixups_are_grouped_and_orphans_are_kept() -> Result<(), Box<dyn std::error::Error>> {
    let repo = TestRepoBuilder::new()?;

    repo.commit("fixup! feat: my-feature")?;
    repo.commit("feat: another-feature")?;

    // act
    let result = commits_with_fixups_on_branch(&repo.repo, "main")?;

    // assert
    assert_eq!(
        result,
        [
            MyCommit {
                subject: "fixup! feat: my-feature".to_string(),
                body: None,
                fixups: Vec::new(),
            },
            MyCommit {
                subject: "feat: another-feature".to_string(),
                body: None,
                fixups: vec![],
            }
        ]
    );

    Ok(())
}

#[test]
fn mr_stack_summary_can_process_test_data() -> Result<(), Box<dyn std::error::Error>> {
    let file =
        std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("../test_utils/src/stack-three.json");

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .args([
            "mr-stack-summary",
            file.to_str().unwrap(),
            "--branch",
            "feature-a",
        ])
        .assert();

    let stderr = String::from_utf8(assert.get_output().stderr.clone())
        .expect("failed to convert stderr to string");
    assert!(stderr.is_empty(), "expected no errors, got: {stderr}");

    let output = String::from_utf8(assert.get_output().stdout.clone())
        .expect("failed to convert stdout to string");
    assert_eq!(
        output,
        [
            "- 👉🏻 **[!101](https://gitlab.example.com/my-group/my-project/-/merge_requests/101)** | Set up authentication module 👈🏻",
            "  - [!102](https://gitlab.example.com/my-group/my-project/-/merge_requests/102) | Implement user profile page",
            "    - [!103](https://gitlab.example.com/my-group/my-project/-/merge_requests/103) | Add input validation to user form",
            "",
        ]
        .join("\n")
    );

    Ok(())
}
