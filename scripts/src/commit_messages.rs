use git2::{BranchType, Error, Repository};

pub fn get_commit_messages_between_commits(
    repo: &Repository,
    start_ref: &str,
    end_ref: &str,
) -> Result<Vec<String>, git2::Error> {
    let start = repo.revparse_single(start_ref)?;
    let end = repo.revparse_single(end_ref)?;
    // TODO if start and end are switched, all commits are printed

    let mut revwalk = repo.revwalk()?;
    revwalk.push(start.id())?;

    let commits_between =
        revwalk
            .take_while(|commit| *commit != Ok(end.id()))
            .map(|commit_result| {
                let commit_id =
                    commit_result.unwrap_or_else(|e| panic!("failed to get commit: {}", e));
                let commit = repo
                    .find_commit(commit_id)
                    .unwrap_or_else(|_| panic!("failed to find commit {}", commit_id));
                commit
            });

    let mut result_lines = Vec::new();

    for commit in commits_between {
        commit_as_markdown(&mut result_lines, commit);
    }

    Ok(result_lines)
}

/// Return the messages of the commits on the given branch
pub fn get_commit_messages_on_branch(
    repo: &Repository,
    branch: &str,
) -> Result<Vec<String>, git2::Error> {
    let start = repo.find_branch(branch, git2::BranchType::Local)?;

    let branch_heads: Vec<git2::Oid> = repo
        .branches(Some(BranchType::Local))?
        .filter_map(|branch_result| {
            if let Ok((branch, _)) = branch_result {
                // ignore this branch
                let oid = branch.get().target()?;
                if oid == start.get().target()? {
                    None
                } else {
                    Some(oid)
                }
            } else {
                None
            }
        })
        .collect::<Vec<_>>();

    let mut revwalk = repo.revwalk()?;
    revwalk.push(start.get().peel_to_commit()?.id())?;

    let lines: Result<Vec<String>, Error> = revwalk
        .take_while(|commit| {
            if let Ok(commit_id) = commit {
                !branch_heads.contains(commit_id)
            } else {
                false
            }
        })
        .try_fold(Vec::new(), |mut results, c| {
            commit_as_markdown(&mut results, repo.find_commit(c?).unwrap());
            Ok(results)
        });

    lines
}

fn commit_as_markdown(result_lines: &mut Vec<String>, commit: git2::Commit<'_>) {
    let first_line = commit
        .summary()
        .unwrap_or_else(|| panic!("failed to get summary for commit {}", commit.id()));
    let body = commit.body().unwrap_or("");

    // format as markdown
    result_lines.push(format!("# {}", first_line));
    result_lines.push("".to_string());

    if !body.is_empty() {
        result_lines.push(body.to_string());
        // TODO remove duplicate empty lines
        result_lines.push("".to_string());
    }
}
