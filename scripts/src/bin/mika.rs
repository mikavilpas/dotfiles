use clap::Parser;
use scripts::{
    arguments::{Cli, Commands},
    commit_messages::{get_commit_messages_between_commits, get_commit_messages_on_branch},
};

pub fn main() {
    let cwd = std::env::current_dir().expect("failed to get current directory");
    let repo = match gix::discover(cwd) {
        Ok(repo) => repo,
        Err(e) => panic!("failed to open: {}", e),
    };
    let cli = Cli::parse();
    match cli.command {
        Commands::Summary { from, to } => {
            let lines = get_commit_messages_between_commits(&repo, &from, &to)
                .unwrap_or_else(|e| panic!("failed to format commit messages: {}", e));

            for l in lines {
                println!("{}", l);
            }
        }
        Commands::BranchSummary { branch } => {
            let lines = get_commit_messages_on_branch(&repo, &branch)
                .unwrap_or_else(|e| panic!("failed to format commit messages: {}", e));

            for l in lines {
                println!("{}", l);
            }
        }
        Commands::UpdatePullRequestDescription {} => {
            //
        }
    }
}
