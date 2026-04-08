use anyhow::{Context, bail};
use std::path::Path;
use std::process::Command;

/// Read a rebase todo file, transform it, and write it back.
/// Used as `GIT_SEQUENCE_EDITOR`.
pub fn edit_rebase_todo(branch: &str, file: &Path) -> anyhow::Result<()> {
    let contents = std::fs::read_to_string(file)
        .with_context(|| format!("failed to read {}", file.display()))?;
    let transformed = transform_todo(branch, &contents);
    std::fs::write(file, transformed)
        .with_context(|| format!("failed to write {}", file.display()))?;
    Ok(())
}

/// Transform a rebase todo list so that only the target branch's fixups are
/// kept. Fixups in all other branches (both before and after) are converted
/// back to `pick` commands.
///
/// See https://git-scm.com/docs/git-rebase#_interactive_mode
fn transform_todo(branch: &str, contents: &str) -> String {
    let target_marker = format!("update-ref refs/heads/{branch}");

    // Group lines into sections, each ending at an update-ref marker.
    let mut sections: Vec<Vec<&str>> = vec![vec![]];
    for line in contents.lines() {
        sections
            .last_mut()
            .expect("sections is never empty")
            .push(line);
        if line.starts_with("update-ref ") {
            sections.push(vec![]);
        }
    }

    let mut result = String::with_capacity(contents.len());
    for section in &sections {
        let is_target = section.iter().any(|l| l.trim() == target_marker);
        for line in section {
            if !is_target && line.starts_with("fixup ") {
                result.push_str("pick ");
                result.push_str(&line["fixup ".len()..]);
            } else {
                result.push_str(line);
            }
            result.push('\n');
        }
    }

    result
}

/// Find the merge-base between `branch` and main/master.
fn find_merge_base(branch: &str) -> anyhow::Result<String> {
    for base_branch in ["main", "master"] {
        let output = Command::new("git")
            .args(["merge-base", branch, base_branch])
            .output()
            .with_context(|| format!("failed to run git merge-base {branch} {base_branch}"))?;

        if output.status.success() {
            return Ok(String::from_utf8(output.stdout)
                .context("git merge-base output is not valid UTF-8")?
                .trim()
                .to_string());
        }
    }

    // Last resort: HEAD~50
    let output = Command::new("git")
        .args(["merge-base", branch, "HEAD~50"])
        .output()
        .context("failed to run git merge-base with HEAD~50 fallback")?;

    if output.status.success() {
        return Ok(String::from_utf8(output.stdout)
            .context("git merge-base output is not valid UTF-8")?
            .trim()
            .to_string());
    }

    bail!("could not find merge-base for branch '{branch}' against main, master, or HEAD~50")
}

/// Run autosquash for a single branch in a stack.
pub fn run_autosquash(branch: &str) -> anyhow::Result<()> {
    let base = find_merge_base(branch)?;

    let mika_path = std::env::current_exe().context("failed to get current executable path")?;
    let sequence_editor = format!(
        "{} autosquash-branch edit-todo --branch {}",
        mika_path.display(),
        branch
    );

    let status = Command::new("git")
        .args(["rebase", "-i", "--autosquash", "--update-refs", &base])
        .env("GIT_SEQUENCE_EDITOR", &sequence_editor)
        .status()
        .context("failed to run git rebase")?;

    if !status.success() {
        bail!("git rebase exited with status {status}");
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn only_target_branch_fixups_are_kept() {
        let input = "\
pick abc123 commit A
fixup def456 fixup! A
update-ref refs/heads/branch1
pick 111aaa commit B
fixup 222bbb fixup! B
update-ref refs/heads/branch2
pick 333ccc commit C
fixup 444ddd fixup! C
update-ref refs/heads/branch3
";
        let result = transform_todo("branch2", input);
        assert_eq!(
            result,
            "\
pick abc123 commit A
pick def456 fixup! A
update-ref refs/heads/branch1
pick 111aaa commit B
fixup 222bbb fixup! B
update-ref refs/heads/branch2
pick 333ccc commit C
pick 444ddd fixup! C
update-ref refs/heads/branch3
"
        );
    }

    #[test]
    fn first_branch_in_stack_keeps_its_fixups() {
        let input = "\
pick abc123 commit A
fixup def456 fixup! A
update-ref refs/heads/branch1
pick 111aaa commit B
fixup 222bbb fixup! B
update-ref refs/heads/branch2
";
        let result = transform_todo("branch1", input);
        assert_eq!(
            result,
            "\
pick abc123 commit A
fixup def456 fixup! A
update-ref refs/heads/branch1
pick 111aaa commit B
pick 222bbb fixup! B
update-ref refs/heads/branch2
"
        );
    }

    #[test]
    fn no_matching_branch_converts_all_fixups_to_picks() {
        let input = "\
pick abc123 commit A
fixup def456 fixup! A
update-ref refs/heads/branch1
pick 111aaa commit B
fixup 222bbb fixup! B
update-ref refs/heads/branch2
";
        let result = transform_todo("nonexistent", input);
        assert_eq!(
            result,
            "\
pick abc123 commit A
pick def456 fixup! A
update-ref refs/heads/branch1
pick 111aaa commit B
pick 222bbb fixup! B
update-ref refs/heads/branch2
"
        );
    }

    #[test]
    fn last_branch_in_stack_keeps_its_fixups() {
        let input = "\
pick abc123 commit A
fixup def456 fixup! A
update-ref refs/heads/branch1
pick 111aaa commit B
fixup 222bbb fixup! B
update-ref refs/heads/branch2
";
        let result = transform_todo("branch2", input);
        assert_eq!(
            result,
            "\
pick abc123 commit A
pick def456 fixup! A
update-ref refs/heads/branch1
pick 111aaa commit B
fixup 222bbb fixup! B
update-ref refs/heads/branch2
"
        );
    }

    #[test]
    fn multiple_fixups_in_target_branch_all_kept() {
        let input = "\
pick abc123 commit A
update-ref refs/heads/branch1
pick 111aaa commit B
fixup 222bbb fixup! B
fixup 333ccc fixup! B
fixup 444ddd fixup! B
update-ref refs/heads/branch2
";
        let result = transform_todo("branch2", input);
        assert_eq!(
            result,
            "\
pick abc123 commit A
update-ref refs/heads/branch1
pick 111aaa commit B
fixup 222bbb fixup! B
fixup 333ccc fixup! B
fixup 444ddd fixup! B
update-ref refs/heads/branch2
"
        );
    }
}
