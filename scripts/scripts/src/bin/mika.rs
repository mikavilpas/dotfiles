use clap::Parser;
use scripts::{
    arguments::{Cli, Commands},
    commit_messages::{
        format_patch_with_instructions, get_commit_messages_between_commits,
        get_commit_messages_on_branch, get_current_branch_name,
    },
    gitlab_mrs::{format_mrs_as_markdown, parse_mrs_from_file, parse_mrs_from_stdin},
    project::path_to_project_file,
};

pub fn main() {
    let cwd = std::env::current_dir().expect("failed to get current directory");
    let repo = match gix::discover(cwd) {
        Ok(repo) => repo,
        Err(e) => panic!("failed to open: {e}"),
    };
    let cli = Cli::parse();
    match cli.command {
        Commands::Summary { from, to } => {
            let lines = get_commit_messages_between_commits(&repo, &from, &to)
                .unwrap_or_else(|e| panic!("failed to format commit messages: {e}"));

            for l in lines {
                println!("{l}");
            }
        }
        Commands::BranchSummary { branch } => {
            let branch = branch.unwrap_or_else(|| {
                get_current_branch_name(&repo)
                    .unwrap_or_else(|e| panic!("failed to get current branch name: {e}"))
            });

            let lines = get_commit_messages_on_branch(&repo, &branch)
                .unwrap_or_else(|e| panic!("failed to format commit messages: {e}"));

            for l in lines {
                println!("{l}");
            }
        }
        Commands::SharePatch {
            commit,
            with_instructions,
        } => {
            let lines = format_patch_with_instructions(&repo, &commit)
                .unwrap_or_else(|e| panic!("failed to format patch: {e}"));

            if with_instructions {
                for line in [
                    "",
                    "<details><summary>Click to expand</summary>",
                    "",
                    "> note: you can copy the diff and then apply it with `pbpaste | git apply --3way`",
                    "",
                    "```diff",
                    &lines,
                    "```",
                    "",
                    "</details>",
                ] {
                    println!("{line}");
                }
            } else {
                println!("{lines}");
            }
        }
        Commands::Path { files } => {
            let cwd = std::env::current_dir().expect("failed to get current directory");
            for file in files {
                let path = {
                    if file.is_absolute() {
                        file
                    } else {
                        cwd.join(file)
                    }
                };
                let target_file = path_to_project_file(&cwd, &path)
                    .unwrap_or_else(|e| panic!("failed to get project file: {e}"));
                println!("{target_file}");
            }
        }
        Commands::MrsSummary { file } => {
            let mrs = if file.as_os_str() == "-" {
                parse_mrs_from_stdin().unwrap_or_else(|e| panic!("failed to parse MRs: {e}"))
            } else {
                let cwd = std::env::current_dir().expect("failed to get current directory");
                let path = if file.is_absolute() {
                    file
                } else {
                    cwd.join(file)
                };
                parse_mrs_from_file(&path).unwrap_or_else(|e| panic!("failed to parse MRs: {e}"))
            };
            let output = format_mrs_as_markdown(mrs);
            println!("{output}");
        }
    }
}
