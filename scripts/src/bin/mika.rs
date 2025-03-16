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
            print_commit_messages_between_commits(&repo, &from, &to)
                .unwrap_or_else(|e| panic!("failed to format commit messages: {}", e));
        }
    }
}

fn print_commit_messages_between_commits(
    repo: &Repository,
    start_ref: &str,
    end_ref: &str,
) -> Result<(), git2::Error> {
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

    for commit in commits_between {
        let first_line = commit
            .summary()
            .unwrap_or_else(|| panic!("failed to get summary for commit {}", commit.id()));
        let body = commit.body().unwrap_or("");

        // format as markdown
        println!("# {}", first_line);
        println!();
        if !body.is_empty() {
            println!("{}", body);
        }
        println!();
    }

    Ok(())
}
