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
    BranchSummary {
        /// The branch to summarize
        #[arg(long)]
        branch: String,
    },

    /// Get a path to repo files, relative to the git repo root. The files don't need to exist.
    Path {
        /// One or more files to get paths for, either absolute or relative to the current directory
        #[arg(
        value_name = "FILE",
        value_hint = clap::ValueHint::AnyPath,
        num_args = 1..,
    )]
        files: Vec<PathBuf>,
    },

    /// Update the description of a pull request on the current branch
    UpdatePr {},
}
