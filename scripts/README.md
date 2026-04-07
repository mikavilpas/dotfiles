# mika

A personal CLI tool for working with various things, including Git, GitHub PRs,
and GitLab MRs.

## Installation

Install with [mise](https://mise.jdx.dev/):

```toml
# .config/mise/config.toml
[tools."github:mikavilpas/dotfiles"]
version = "1.2.0" # or "latest"
exe = "mika"
postinstall = """
mkdir -p ~/.config/fish/completions ~/.config/fish/mika
# run initialization for the fish shell after installing / updating
mika init fish --output-dir ~/.config/fish/mika/
"""
```

```bash
mise install "github:mikavilpas/dotfiles"
```

Then add this to your `config.fish` (one-time setup, for lazy-loaded shell
functions):

```fish
set --append fish_function_path ~/.config/fish/mika
```

## Shell integration (fish)

Some related utilities are provided for integrating with other tools. To install
them as well, follow these steps:

1. Add a mise postinstall hook as described in [[#Shell integration (fish)]].
2. Then add this to your `config.fish` (one-time setup):

   ```fish
   set --append fish_function_path ~/.config/fish/mika
   ```

   The functions are lazy-loaded by fish, so there is no shell startup cost.

Run `mika --help` or `mika <command> --help` for details.
