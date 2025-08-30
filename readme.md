# My dotfiles

This is the configuration for my personal development environment.

I use this repository to

- explain and share ideas with others
- share the configuration between my machines
- keep track of the changes I make to my configuration
- run end-to-end tests in Github Actions
  - Microsoft (owner of Github) graciously offers this for free for public
    repositories (sources:
    [2019 announcement](https://github.blog/news-insights/product-news/github-actions-now-supports-ci-cd/),
    ["The use of these runners on public repositories is free and unlimited"](https://docs.github.com/en/actions/how-tos/write-workflows/choose-where-workflows-run/choose-the-runner-for-a-job#standard-github-hosted-runners-for-public-repositories))

## Keyboard

My keyboard is an [ErgoDox EZ](https://ergodox-ez.com/). It is a split keyboard
with mechanical switches.

## Keyboard layout

![Image of my keyboard layout](./assets/keyboard.png)

My keyboard layout is based on
[DAS](https://web.archive.org/web/20231108015515/https://c.seres.fi/das), a
layout optimized for the Finnish language created by Cristian Seres.

The layout and all its customizations are embedded in the keyboard's firmware
using [QMK](https://qmk.fm/).

## Installation

Because this is a personal configuration, it is not meant to be installed by
others. However, you can use it as a reference for your own configuration.

Here are the basics:

### Dotfile management

I manage my dotfiles with GNU Stow. It creates symlinks from the repository to
the home directory. See
[here](https://dev.to/spacerockmedia/how-i-manage-my-dotfiles-using-gnu-stow-4l59)
for an introduction by Shawn McElroy.

This way I can keep the configuration under version control and still have it in
the home directory.

```sh
# Sync the dotfiles (practice run)
stow --verbose 2 . --simulate

# Really sync the dotfiles
stow --verbose 2 .
```

### Dependency management

Many of the packages I use have some kind of custom dependencies:

- neovim plugins are managed using [lazy.nvim](https://lazy.folke.io/)
- my terminal file manager is [yazi](https://github.com/sxyazi/yazi/). Its
  plugins are managed using lazy.nvim as well. The approach is explained in
  detail in yazi.nvim's
  [plugin-management.md](https://github.com/mikavilpas/yazi.nvim/blob/main/documentation/plugin-management.md).
  The config is available [here](.config/nvim/lua/plugins/my-file-manager.lua),
  but the short version is that it uses lazy.nvim to download and update the
  dependencies, and then creates symlinks whenever they are installed/updated.
- plugins for other applications are also managed with the same approach to keep
  things simple. An example can be seen
  [here](.config/nvim/lua/plugins/dotfiles.lua).

### Testing

Instead of managing an installation script, I have a test that I can run in
neovim.

The test checks that I have all the applications installed, and acts as a
reminder.

```vim
" in neovim
:checkhealth
```

#### Continuous integration

I have an end-to-end testing setup in [integration-tests](./integration-tests).
It uses <https://github.com/mikavilpas/tui-sandbox> to run the tests.

Lately I have been experimenting with implementing common development
[scripts](./scripts) in rust. These are also e2e tested with Github Actions.

### Formatting

Here is how the files in this repository are formatted. Since I am the only
maintainer, most use the editor's "format on save" functionality.

| Filetype | Formatter                                 | Notes                   |
| -------- | ----------------------------------------- | ----------------------- |
| Markdown | [prettier](https://prettier.io/)          |                         |
| TOML     | [taplo](https://github.com/tamasfe/taplo) | Run with `taplo format` |

### Git

I use [lazygit](https://github.com/jesseduffield/lazygit) and the
[tsugit.nvim](https://github.com/mikavilpas/tsugit.nvim) plugin to use git.

Some features that I like:

- an AI (in my case, Github Copilot) helps me write commit messages in Neovim
  when using tsugit.nvim
- I set up [conform.nvim](https://github.com/stevearc/conform.nvim) to use
  [prettierd](https://github.com/fsouza/prettierd) to format my gitcommit
  messages using markdown syntax. See my
  [conform.nvim configuration](.config/nvim/lua/plugins/formatting.lua) for
  details on how I did it.
