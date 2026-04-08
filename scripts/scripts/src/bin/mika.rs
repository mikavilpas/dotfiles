use clap::Parser;
use std::process::exit;

use scripts::{
    arguments::{AutosquashSubcommand, Cli, Commands, InitShell, MrsFormat, PrsFormat},
    commit_messages::{
        format_patch_with_instructions, get_commit_messages_between_commits,
        get_commit_messages_on_branch, get_current_branch_name,
    },
    github::github_prs::{self, format_prs_as_markdown, parse_github_prs_from_file_or_stdin},
    gitlab::gitlab_mrs::{
        OutputFormat, format_mrs_as_markdown, mr_stack, parse_gitlab_mrs_from_file_or_stdin,
    },
    project::path_to_project_file,
};

pub fn main() {
    let cli = match Cli::try_parse() {
        Ok(cli) => cli,
        Err(e) => e.exit(),
    };

    // Handle commands that don't need a git repo
    if let Commands::AutosquashBranch { command } = &cli.command {
        match command {
            AutosquashSubcommand::Run { branch } => {
                if let Err(e) = scripts::autosquash::run_autosquash(branch) {
                    eprintln!("failed to autosquash branch: {e}");
                    exit(1);
                }
            }
            AutosquashSubcommand::EditTodo { branch, file } => {
                if let Err(e) = scripts::autosquash::edit_rebase_todo(branch, file) {
                    eprintln!("failed to edit rebase todo: {e}");
                    exit(1);
                }
            }
        }
        return;
    }

    if let Commands::Init { shell, output_dir } = &cli.command {
        match shell {
            InitShell::Fish => match scripts::init::write_fish_init(output_dir) {
                Ok(summary) => {
                    println!("{summary}");
                }
                Err(e) => {
                    eprintln!("failed to write fish init files: {e}");
                    exit(1);
                }
            },
        }
        return;
    }

    let cwd = std::env::current_dir().expect("failed to get current directory");
    let repo = match gix::discover(cwd) {
        Ok(repo) => repo,
        Err(e) => panic!("failed to open: {e}"),
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

        Commands::PrsSummary { file, format } => {
            let prs = parse_github_prs_from_file_or_stdin(file);
            let output_format = match format {
                PrsFormat::Links => github_prs::OutputFormat::Links,
                PrsFormat::Branches => github_prs::OutputFormat::Branches,
            };
            match format_prs_as_markdown(prs, output_format) {
                Ok(output) => println!("{output}"),
                Err(e) => {
                    eprintln!("failed to format PRs: {e}");
                    exit(1);
                }
            };
        }

        Commands::PrStackSummary { file, branch } => {
            let prs = parse_github_prs_from_file_or_stdin(file);
            let branch = branch.unwrap_or_else(|| {
                get_current_branch_name(&repo)
                    .unwrap_or_else(|e| panic!("failed to get current branch name: {e}"))
            });

            match github_prs::pr_stack::format_pr_stack_as_markdown(prs, branch.as_str()) {
                Ok(output) => println!("{output}"),
                Err(error) => {
                    eprintln!("failed to format PR stack: {error}");
                    exit(1);
                }
            };
        }

        // Already handled above before git repo discovery
        Commands::AutosquashBranch { .. } => unreachable!(),
        Commands::Init { .. } => unreachable!(),
    }
}
