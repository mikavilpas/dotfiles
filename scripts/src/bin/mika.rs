use clap::Parser;
use git2::Repository;
use scripts::arguments::{Cli, Commands};

pub fn main() {
    let cwd = std::env::current_dir().expect("failed to get current directory");
    let repo = match Repository::discover(cwd) {
        Ok(repo) => repo,
        Err(e) => panic!("failed to open: {}", e),
    };
    let cli = Cli::parse();
    match cli.command {
        Commands::Summary { from, to } => {
            let lines = print_commit_messages_between_commits(&repo, &from, &to)
                .unwrap_or_else(|e| panic!("failed to format commit messages: {}", e));

            for l in lines {
                println!("{}", l);
            }
        }
    }
}

fn print_commit_messages_between_commits(
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
        let first_line = commit
            .summary()
            .unwrap_or_else(|| panic!("failed to get summary for commit {}", commit.id()));
        let body = commit.body().unwrap_or("");

        // format as markdown
        result_lines.push(format!("# {}", first_line));
        result_lines.push("".to_string());

        if !body.is_empty() {
            result_lines.push(body.to_string());
        }
        result_lines.push("".to_string());
    }

    Ok(result_lines)
}

#[cfg(test)]
mod test {
    use git2::Error;

    use super::*;

    #[test]
    fn test_print_commit_messages_between_commits() -> Result<(), Box<dyn std::error::Error>> {
        // create a temporary test repo with a few commits
        let tmpdir = tempfile::tempdir()?;

        let repo = Repository::init(tmpdir.path())?;
        repo.config()?.set_str("user.name", "test")?;
        repo.config()?.set_str("user.email", "test@example.com")?;
        create_commits(&repo)?;

        let (a, b) = {
            let mut revwalk = repo.revwalk()?;
            revwalk.push_head()?;

            let first = revwalk.next().unwrap()?;
            let second = revwalk.next().unwrap()?;

            (first, second)
        };
        assert_eq!(a, repo.head()?.target().unwrap());

        let result_lines =
            print_commit_messages_between_commits(&repo, &a.to_string(), &(b.to_string() + "^"))?;

        assert_eq!(result_lines, vec![
            "# feat: commit 1",
            "",
            "",
            "# feat: commit 0",
            "",
            "",
        ]);

        Ok(())
    }

    fn create_commits(repo: &Repository) -> Result<(), Error> {
        let sig = repo.signature()?;
        let tree = {
            let tree_id = {
                let mut index = repo.index()?;
                index.write_tree()?
            };
            repo.find_tree(tree_id)?
        };

        let mut previous =
            repo.commit(Some("HEAD"), &sig, &sig, "chore: initial commit", &tree, &[
            ])?;
        for i in 0..2 {
            let message = format!("feat: commit {}", i);
            let previous_commit = repo.find_commit(previous)?;
            previous = repo.commit(Some("HEAD"), &sig, &sig, &message, &tree, &[
                &previous_commit,
            ])?;
        }

        Ok(())
    }
}
