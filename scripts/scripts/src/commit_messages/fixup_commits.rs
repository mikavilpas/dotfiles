use super::create_commit;
use crate::commit_messages::{my_commit::MyCommit, stack_branch};
use anyhow::Context;
use gix::Repository;

pub fn commits_with_fixups_on_branch<S: AsRef<str> + std::fmt::Display>(
    repo: &Repository,
    branch: S,
) -> anyhow::Result<Vec<MyCommit>, anyhow::Error> {
    // collect all commits on the branch
    let mut commits: Vec<Option<MyCommit>> = {
        let mut revwalk = stack_branch::stack_branch_iterator(repo, branch)?.peekable();
        let mut commits = Vec::new();
        while let Some(commit) = revwalk.next().transpose()? {
            let commit = repo
                .find_commit(commit.id)
                .with_context(|| format!("failed to find the commit {}", commit.id))?;
            let commit = create_commit(&commit)?;
            commits.push(Some(commit));
        }
        commits.reverse();
        commits
    };

    // iterate backwards through the commits, trying to move fixup commits to their base commits
    for i in (0..commits.len()).rev() {
        if let Some(commit) = commits[i].take_if(|c| c.is_fixup()) {
            assert!(commits[i].is_none());
            match find_base_commit_index_for_fixup(&commit, i, &commits) {
                None => {
                    // put the commit back if no base commit is found. It's been taken out and we
                    // don't want to lose it.
                    eprintln!("warn: no base commit found for fixup at index {}", i);
                    commits[i].replace(commit);
                }
                Some(base_commit_index) => {
                    let mut base_commit = commits[base_commit_index]
                        .take()
                        .expect("base commit must exist");
                    base_commit.fixups.push(commit);
                    commits[base_commit_index].replace(base_commit);
                }
            }
        } else {
            eprintln!("commit at index {} is not a fixup", i);
        }
    }

    // remove all None values
    Ok(commits.into_iter().flatten().collect())
}

fn find_base_commit_index_for_fixup(
    fixup_commit: &MyCommit,
    fixup_index: usize,
    commits: &[Option<MyCommit>],
) -> Option<usize> {
    let target_subject = fixup_commit.normalized_subject();

    commits[..fixup_index]
        .iter()
        .rposition(|c| c.as_ref().is_some_and(|c| c.subject == target_subject))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn create_test_commit(subject: &str) -> MyCommit {
        MyCommit {
            subject: subject.to_string(),
            body: None,
            fixups: vec![],
        }
    }

    #[test]
    fn test_find_base_commit_index_for_fixup() -> anyhow::Result<(), anyhow::Error> {
        let commits = Vec::from([
            Some(create_test_commit("feat: add feature")),
            Some(create_test_commit("fixup! feat: add feature")),
        ]);

        let fixup_commit = commits[1].as_ref().expect("commit should exist");

        let base_index = find_base_commit_index_for_fixup(fixup_commit, 1, &commits);
        assert_eq!(base_index, Some(0));

        Ok(())
    }

    #[test]
    fn test_find_base_commit_index_for_fixup_not_found() -> anyhow::Result<(), anyhow::Error> {
        let commits = Vec::from([Some(create_test_commit("fixup! feat: add feature"))]);
        let fixup_commit = commits[0].as_ref().expect("commit should exist");

        let base_index = find_base_commit_index_for_fixup(fixup_commit, 0, &commits);
        assert_eq!(base_index, None);

        Ok(())
    }

    #[test]
    fn test_find_base_commit_index_for_fixup_picks_first_base_commit()
    -> anyhow::Result<(), anyhow::Error> {
        let wrong_commit = create_test_commit("feat: add feature");
        let mut right_commit = create_test_commit("feat: add feature");
        right_commit
            // since the commits look exactly the same, make this one unique so we can tell them
            // apart
            .fixups
            .push(create_test_commit("marker commit"));

        let commits = Vec::from([
            Some(wrong_commit),
            Some(right_commit),
            Some(create_test_commit("fixup! feat: add feature")),
        ]);

        let fixup_commit = commits[2].as_ref().expect("commit should exist");

        let base_index = find_base_commit_index_for_fixup(fixup_commit, 2, &commits);
        assert_eq!(base_index, Some(1));

        Ok(())
    }
}
