use std::{fs, path::Path};

use arguments::Cli;
use clap::CommandFactory;
use clap_complete::{aot::Fish, generate_to};

#[path = "./src/arguments.rs"]
mod arguments;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let completions_dir = Path::new("completions");

    // Ensure the directory exists
    if !completions_dir.exists() {
        fs::create_dir_all(completions_dir)?;
    }

    let cmd = &mut Cli::command();
    generate_to(Fish, cmd, "mika", completions_dir)?;

    Ok(())
}
