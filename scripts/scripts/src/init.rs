use std::fs;
use std::path::Path;

use clap::CommandFactory;
use clap_complete::aot::Fish;
use clap_complete::generate;

use crate::arguments::Cli;

/// Write fish shell function and completion files to the given output directory.
///
/// - Deletes all existing `.fish` files in the directory first (to clean up stale functions)
/// - Creates the directory if it doesn't exist
/// - Writes one file per function, plus a completions file
pub fn write_fish_init(output_dir: &Path) -> std::io::Result<String> {
    // Create the directory if it doesn't exist
    fs::create_dir_all(output_dir)?;

    // Delete all existing .fish files to clean up stale functions
    if output_dir.exists() {
        for entry in fs::read_dir(output_dir)? {
            let entry = entry?;
            let path = entry.path();
            if path.extension().and_then(|e| e.to_str()) == Some("fish") {
                fs::remove_file(&path)?;
            }
        }
    }

    let files: Vec<(&str, &str)> = vec![
        (
            "prs.fish",
            r#"function prs --description "Show GitHub pull requests"
    gh pr list --author=@me --json number,title,url,headRefName,baseRefName,isDraft | mika prs-summary - --format=branches
end
"#,
        ),
        (
            "mrs.fish",
            r#"function mrs --description "Show GitLab merge requests"
    glab mr list --author=@me --output=json | mika mrs-summary - --format=branches
end
"#,
        ),
    ];

    let mut summary_lines = Vec::new();
    for (filename, content) in &files {
        let file_path = output_dir.join(filename);
        fs::write(&file_path, content)?;
        summary_lines.push(format!("  wrote {}", file_path.display()));
    }

    // Generate and write fish completions
    let completions_path = output_dir.join("mika.fish");
    let mut buf = Vec::new();
    let cmd = &mut Cli::command();
    generate(Fish, cmd, "mika", &mut buf);
    fs::write(&completions_path, buf)?;
    summary_lines.push(format!("  wrote {}", completions_path.display()));

    let total = files.len() + 1; // functions + completions
    Ok(format!(
        "Wrote {total} fish files to {}:\n{}",
        output_dir.display(),
        summary_lines.join("\n")
    ))
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn creates_output_directory_if_missing() {
        let tmp = TempDir::new().unwrap();
        let output_dir = tmp.path().join("nonexistent/subdir");
        assert!(!output_dir.exists());

        write_fish_init(&output_dir).unwrap();

        assert!(output_dir.exists());
        assert!(output_dir.join("prs.fish").exists());
        assert!(output_dir.join("mrs.fish").exists());
        assert!(output_dir.join("mika.fish").exists());
    }

    #[test]
    fn cleans_up_old_fish_files() {
        let tmp = TempDir::new().unwrap();
        let output_dir = tmp.path().join("fish");
        fs::create_dir_all(&output_dir).unwrap();

        // Create a stale .fish file
        let stale_file = output_dir.join("old_function.fish");
        fs::write(&stale_file, "stale content").unwrap();
        assert!(stale_file.exists());

        write_fish_init(&output_dir).unwrap();

        // Stale file should be gone
        assert!(!stale_file.exists());
        // New files should exist
        assert!(output_dir.join("prs.fish").exists());
        assert!(output_dir.join("mrs.fish").exists());
        assert!(output_dir.join("mika.fish").exists());
    }

    #[test]
    fn writes_correct_prs_content() {
        let tmp = TempDir::new().unwrap();
        write_fish_init(tmp.path()).unwrap();

        let content = fs::read_to_string(tmp.path().join("prs.fish")).unwrap();
        assert!(content.contains("function prs --description \"Show GitHub pull requests\""));
        assert!(content.contains("gh pr list --author=@me"));
        assert!(content.contains("mika prs-summary"));
    }

    #[test]
    fn writes_correct_mrs_content() {
        let tmp = TempDir::new().unwrap();
        write_fish_init(tmp.path()).unwrap();

        let content = fs::read_to_string(tmp.path().join("mrs.fish")).unwrap();
        assert!(content.contains("function mrs --description \"Show GitLab merge requests\""));
        assert!(content.contains("glab mr list --author=@me"));
        assert!(content.contains("mika mrs-summary"));
    }

    #[test]
    fn writes_fish_completions() {
        let tmp = TempDir::new().unwrap();
        write_fish_init(tmp.path()).unwrap();

        let content = fs::read_to_string(tmp.path().join("mika.fish")).unwrap();
        assert!(content.contains("complete -c mika"));
        assert!(content.contains("summary"));
        assert!(content.contains("branch-summary"));
    }

    #[test]
    fn does_not_delete_non_fish_files() {
        let tmp = TempDir::new().unwrap();
        let other_file = tmp.path().join("keep_me.txt");
        fs::write(&other_file, "important").unwrap();

        write_fish_init(tmp.path()).unwrap();

        assert!(other_file.exists());
    }

    #[test]
    fn returns_summary_of_written_files() {
        let tmp = TempDir::new().unwrap();
        let summary = write_fish_init(tmp.path()).unwrap();

        assert!(summary.contains("Wrote 3 fish files"));
        assert!(summary.contains("prs.fish"));
        assert!(summary.contains("mrs.fish"));
        assert!(summary.contains("mika.fish"));
    }
}
