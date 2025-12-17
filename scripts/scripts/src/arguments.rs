use std::path::PathBuf;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "mika", version, about, long_about = None)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Summarize commits in markdown format, for quick PR descriptions
    Summary {
        /// The start ref, e.g. HEAD in (HEAD..main)
        #[arg(long)]
        from: String,

        /// The end ref, e.g. main in (HEAD..main)
        #[arg(long)]
        to: String,
    },

    /// Summarize the commits on the given branch, before any other local branch is reached.
    /// Defaults to the current branch.
    BranchSummary {
        /// The branch to summarize
        #[arg(long)]
        branch: Option<String>,
    },

    /// Share a patch in a PR for the given commit, or the current HEAD if not specified.
    SharePatch {
        /// The commit (or range) to share, defaults to the current HEAD
        #[arg(long, default_value = "HEAD")]
        commit: String,

        /// Whether to include instructions for applying the patch. So that code reviewers can
        /// easily apply the patch even if they don't know how to use the related git commands.
        /// Defaults to true.
        #[arg(long, default_value_t = true)]
        with_instructions: bool,
    },

    /// Get a path to repo files, relative to the git repo root. The files don't need to exist.
    Path {
        /// One or more files to get paths for, either absolute or relative to the current
        /// directory
        #[arg(
        value_name = "FILE",
        value_hint = clap::ValueHint::AnyPath,
        num_args = 1..,
    )]
        files: Vec<PathBuf>,
    },

    /// Display a markdown summary of GitLab merge requests from a JSON file
    MrsSummary {
        /// Path to the JSON file containing GitLab MRs (from GitLab API), or "-" to read from stdin
        #[arg(value_name = "FILE", value_hint = clap::ValueHint::FilePath)]
        file: PathBuf,
    },
}
