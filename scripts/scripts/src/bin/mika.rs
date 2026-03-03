use clap::Parser;
use std::process::exit;

use scripts::{
    arguments::{Cli, Commands, MrsFormat},
    commit_messages::{
        format_patch_with_instructions, get_commit_messages_between_commits,
        get_commit_messages_on_branch, get_current_branch_name,
    },
    gitlab::gitlab_mrs::{
        OutputFormat, format_mrs_as_markdown, mr_stack, parse_gitlab_mrs_from_file_or_stdin,
    },
    project::path_to_project_file,
};

pub fn main() {
    let cwd = std::env::current_dir().expect("failed to get current directory");
    let repo = match gix::discover(cwd) {
        Ok(repo) => repo,
        Err(e) => panic!("failed to open: {e}"),
    };
    let cli = match Cli::try_parse() {
        Ok(cli) => cli,
        Err(e) => e.exit(),
    };
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
        Commands::MrsSummary { file, format } => {
            let mrs = parse_gitlab_mrs_from_file_or_stdin(file);
            let output_format = match format {
                MrsFormat::Links => OutputFormat::Links,
                MrsFormat::Branches => OutputFormat::Branches,
            };
            match format_mrs_as_markdown(mrs, output_format) {
                Ok(output) => println!("{output}"),
                Err(e) => {
                    eprintln!("failed to format MRs: {e}");
                    exit(1);
                }
            };
        }

        Commands::MrStackSummary { file, branch } => {
            let mrs = parse_gitlab_mrs_from_file_or_stdin(file);
            let branch = branch.unwrap_or_else(|| {
                get_current_branch_name(&repo)
                    .unwrap_or_else(|e| panic!("failed to get current branch name: {e}"))
            });

            match mr_stack::format_mr_stack_as_markdown(mrs, branch.as_str()) {
                Ok(output) => println!("{output}"),
                Err(error) => {
                    eprintln!("failed to format MR stack: {error}");
                    exit(1);
                }
            };
        }
    }
}
