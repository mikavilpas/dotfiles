use assert_cmd::cargo;
use pretty_assertions::assert_eq;
use scripts::gitlab::gitlab_mrs::MergeRequest;
use std::io::Write;
use tempfile::NamedTempFile;

fn create_mrs_json(mrs: &[MergeRequest]) -> NamedTempFile {
    let mut file = NamedTempFile::new().expect("failed to create temp file");
    let json = serde_json::to_string(mrs).expect("failed to serialize MRs");
    file.write_all(json.as_bytes())
        .expect("failed to write MRs JSON");
    file
}

fn create_mr(
    iid: u64,
    title: &str,
    source_branch: &str,
    target_branch: &str,
    draft: bool,
) -> MergeRequest {
    MergeRequest {
        iid,
        title: title.to_string(),
        web_url: format!(
            "https://gitlab.example.com/acme/webapp/-/merge_requests/{}",
            iid
        ),
        source_branch: source_branch.to_string(),
        target_branch: target_branch.to_string(),
        draft,
    }
}

#[test]
fn test_mrs_summary_single_mr() {
    let mrs = vec![create_mr(
        101,
        "feat: add user authentication",
        "feature-auth",
        "main",
        false,
    )];
    let file = create_mrs_json(&mrs);

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .args(["mrs-summary", file.path().to_str().unwrap()])
        .assert();

    let stdout = String::from_utf8(assert.success().get_output().stdout.clone())
        .expect("failed to convert stdout to string");

    assert_eq!(
        stdout,
        [
            "- [!101](https://gitlab.example.com/acme/webapp/-/merge_requests/101) feat: add user authentication",
            "",
        ]
        .join("\n")
    );
}

#[test]
fn test_mrs_summary_draft_mr() {
    let mrs = vec![create_mr(
        102,
        "Draft: refactor: migrate to new API client",
        "refactor-api",
        "main",
        true,
    )];
    let file = create_mrs_json(&mrs);

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .args(["mrs-summary", file.path().to_str().unwrap()])
        .assert();

    let stdout = String::from_utf8(assert.success().get_output().stdout.clone())
        .expect("failed to convert stdout to string");

    assert_eq!(
        stdout,
        [
            "- [!102](https://gitlab.example.com/acme/webapp/-/merge_requests/102) **Draft:** refactor: migrate to new API client",
            "",
        ]
        .join("\n")
    );
}

#[test]
fn test_mrs_summary_nested_mrs() {
    // MR 102 targets 101's source branch, so it should be nested under 101
    let mrs = vec![
        create_mr(
            101,
            "feat: base authentication system",
            "feature-auth",
            "main",
            false,
        ),
        create_mr(
            102,
            "feat: add OAuth support",
            "feature-oauth",
            "feature-auth", // targets 101's source branch
            false,
        ),
    ];
    let file = create_mrs_json(&mrs);

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .args(["mrs-summary", file.path().to_str().unwrap()])
        .assert();

    let stdout = String::from_utf8(assert.success().get_output().stdout.clone())
        .expect("failed to convert stdout to string");

    assert_eq!(
        stdout,
        [
            "- [!101](https://gitlab.example.com/acme/webapp/-/merge_requests/101) feat: base authentication system",
            "  - [!102](https://gitlab.example.com/acme/webapp/-/merge_requests/102) feat: add OAuth support",
            "",
        ]
        .join("\n")
    );
}

#[test]
fn test_mrs_summary_deeply_nested_mrs() {
    // Create a chain: 101 <- 102 <- 103 (three levels deep)
    let mrs = vec![
        create_mr(101, "feat: database layer", "feature-db", "main", false),
        create_mr(
            102,
            "feat: caching layer",
            "feature-cache",
            "feature-db", // targets 101
            false,
        ),
        create_mr(
            103,
            "feat: API endpoints",
            "feature-api",
            "feature-cache", // targets 102
            false,
        ),
    ];
    let file = create_mrs_json(&mrs);

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .args(["mrs-summary", file.path().to_str().unwrap()])
        .assert();

    let stdout = String::from_utf8(assert.success().get_output().stdout.clone())
        .expect("failed to convert stdout to string");

    assert_eq!(
        stdout,
        [
            "- [!101](https://gitlab.example.com/acme/webapp/-/merge_requests/101) feat: database layer",
            "  - [!102](https://gitlab.example.com/acme/webapp/-/merge_requests/102) feat: caching layer",
            "    - [!103](https://gitlab.example.com/acme/webapp/-/merge_requests/103) feat: API endpoints",
            "",
        ]
        .join("\n")
    );
}

#[test]
fn test_mrs_summary_multiple_roots_sorted_by_iid() {
    // Multiple MRs targeting main, should be sorted by iid ascending
    let mrs = vec![
        create_mr(105, "chore: update CI config", "chore-ci", "main", false),
        create_mr(101, "feat: add logging", "feature-logging", "main", false),
        create_mr(103, "fix: memory leak", "fix-memory", "main", false),
    ];
    let file = create_mrs_json(&mrs);

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .args(["mrs-summary", file.path().to_str().unwrap()])
        .assert();

    let stdout = String::from_utf8(assert.success().get_output().stdout.clone())
        .expect("failed to convert stdout to string");

    assert_eq!(
        stdout,
        [
            "- [!101](https://gitlab.example.com/acme/webapp/-/merge_requests/101) feat: add logging",
            "- [!103](https://gitlab.example.com/acme/webapp/-/merge_requests/103) fix: memory leak",
            "- [!105](https://gitlab.example.com/acme/webapp/-/merge_requests/105) chore: update CI config",
            "",
        ]
        .join("\n")
    );
}

#[test]
fn test_mrs_summary_empty() {
    let mrs: Vec<MergeRequest> = vec![];
    let file = create_mrs_json(&mrs);

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .args(["mrs-summary", file.path().to_str().unwrap()])
        .assert();

    let stderr = String::from_utf8(assert.failure().get_output().stderr.clone())
        .expect("failed to convert stdout to string");

    assert_eq!(
        stderr,
        ["failed to format MRs: No open merge requests.", ""].join("\n")
    );
}

#[test]
fn test_mrs_summary_complex_tree() {
    // Create a complex tree structure:
    // - !101 (root - targets main)
    // - !102 (root - targets main)
    //   - !103 (child of 102)
    //     - !104 (child of 103)
    //       - !105 (child of 104)
    //         - !106 (child of 105)
    //       - !107 (child of 104)
    //         - !108 (child of 107)
    let mrs = vec![
        create_mr(
            101,
            "feat: standalone feature",
            "feature-standalone",
            "main",
            false,
        ),
        create_mr(
            102,
            "test: add integration tests",
            "test-integration",
            "main",
            false,
        ),
        create_mr(
            103,
            "Draft: refactor: extract common utils",
            "refactor-utils",
            "test-integration", // targets 102
            true,
        ),
        create_mr(
            104,
            "Draft: chore: upgrade dependencies",
            "chore-deps",
            "refactor-utils", // targets 103
            true,
        ),
        create_mr(
            105,
            "Draft: feat: add new widget",
            "feature-widget",
            "chore-deps", // targets 104
            true,
        ),
        create_mr(
            106,
            "feat: widget animations",
            "feature-animations",
            "feature-widget", // targets 105
            false,
        ),
        create_mr(
            107,
            "Draft: fix: button accessibility",
            "fix-a11y",
            "chore-deps", // targets 104
            true,
        ),
        create_mr(
            108,
            "Draft: refactor: download service",
            "refactor-download",
            "fix-a11y", // targets 107
            true,
        ),
    ];
    let file = create_mrs_json(&mrs);

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .args(["mrs-summary", file.path().to_str().unwrap()])
        .assert();

    let stdout = String::from_utf8(assert.success().get_output().stdout.clone())
        .expect("failed to convert stdout to string");

    assert_eq!(
        stdout,
        [
            "- [!101](https://gitlab.example.com/acme/webapp/-/merge_requests/101) feat: standalone feature",
            "- [!102](https://gitlab.example.com/acme/webapp/-/merge_requests/102) test: add integration tests",
            "  - [!103](https://gitlab.example.com/acme/webapp/-/merge_requests/103) **Draft:** refactor: extract common utils",
            "    - [!104](https://gitlab.example.com/acme/webapp/-/merge_requests/104) **Draft:** chore: upgrade dependencies",
            "      - [!105](https://gitlab.example.com/acme/webapp/-/merge_requests/105) **Draft:** feat: add new widget",
            "        - [!106](https://gitlab.example.com/acme/webapp/-/merge_requests/106) feat: widget animations",
            "      - [!107](https://gitlab.example.com/acme/webapp/-/merge_requests/107) **Draft:** fix: button accessibility",
            "        - [!108](https://gitlab.example.com/acme/webapp/-/merge_requests/108) **Draft:** refactor: download service",
            "",
        ]
        .join("\n")
    );
}

#[test]
fn test_mrs_summary_from_stdin() {
    let mrs = vec![
        create_mr(101, "feat: first feature", "feature-first", "main", false),
        create_mr(
            102,
            "feat: second feature",
            "feature-second",
            "feature-first",
            false,
        ),
    ];
    let json = serde_json::to_string(&mrs).expect("failed to serialize MRs");

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd.args(["mrs-summary", "-"]).write_stdin(json).assert();

    let stdout = String::from_utf8(assert.success().get_output().stdout.clone())
        .expect("failed to convert stdout to string");

    assert_eq!(
        stdout,
        [
            "- [!101](https://gitlab.example.com/acme/webapp/-/merge_requests/101) feat: first feature",
            "  - [!102](https://gitlab.example.com/acme/webapp/-/merge_requests/102) feat: second feature",
            "",
        ]
        .join("\n")
    );
}

#[test]
fn test_mrs_summary_branches_format() {
    let mrs = vec![
        create_mr(101, "feat: base feature", "feature-base", "main", false),
        create_mr(
            102,
            "Draft: child feature",
            "feature-child",
            "feature-base",
            true,
        ),
        create_mr(103, "feat: another root", "feature-another", "main", false),
    ];
    let file = create_mrs_json(&mrs);

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .args([
            "mrs-summary",
            file.path().to_str().unwrap(),
            "--format=branches",
        ])
        .assert();

    let stdout = String::from_utf8(assert.success().get_output().stdout.clone())
        .expect("failed to convert stdout to string");

    // OSC 8 hyperlink format: \x1b]8;;URL\x1b\\TEXT\x1b]8;;\x1b\\
    assert_eq!(
        stdout,
        [
            "- `\x1b]8;;https://gitlab.example.com/acme/webapp/-/merge_requests/101\x1b\\feature-base\x1b]8;;\x1b\\` feat: base feature",
            "  - `\x1b]8;;https://gitlab.example.com/acme/webapp/-/merge_requests/102\x1b\\feature-child\x1b]8;;\x1b\\` **Draft:** child feature",
            "- `\x1b]8;;https://gitlab.example.com/acme/webapp/-/merge_requests/103\x1b\\feature-another\x1b]8;;\x1b\\` feat: another root",
            "",
        ]
        .join("\n")
    );
}

#[test]
fn test_mrs_summary_branches_format_from_stdin() {
    let mrs = vec![
        create_mr(101, "feat: first", "branch-first", "main", false),
        create_mr(102, "feat: second", "branch-second", "branch-first", false),
    ];
    let json = serde_json::to_string(&mrs).expect("failed to serialize MRs");

    let mut cmd = cargo::cargo_bin_cmd!("mika");
    let assert = cmd
        .args(["mrs-summary", "-", "--format=branches"])
        .write_stdin(json)
        .assert();

    let stdout = String::from_utf8(assert.success().get_output().stdout.clone())
        .expect("failed to convert stdout to string");

    // OSC 8 hyperlink format: \x1b]8;;URL\x1b\\TEXT\x1b]8;;\x1b\\
    assert_eq!(
        stdout,
        [
            "- `\x1b]8;;https://gitlab.example.com/acme/webapp/-/merge_requests/101\x1b\\branch-first\x1b]8;;\x1b\\` feat: first",
            "  - `\x1b]8;;https://gitlab.example.com/acme/webapp/-/merge_requests/102\x1b\\branch-second\x1b]8;;\x1b\\` feat: second",
            "",
        ]
        .join("\n")
    );
}
