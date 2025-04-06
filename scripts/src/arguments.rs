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

    /// Update the description of a pull request
    UpdatePullRequestDescription {},
}
