# My dotfiles

This is the configuration for my personal development environment.

I use this repository to

- share ideas with others
- share the configuration between my machines
- keep track of the changes I make to my configuration

## Installation

Because this is a personal configuration, it is not meant to be installed by
others. However, you can use it as a reference for your own configuration.

Here are the basics:

### Dotfile management

I manage my dotfiles with GNU Stow. It creates symlinks from the repository to
the home directory.

This way I can keep the configuration under version control and still have it in
the home directory.

```sh
# Sync the dotfiles (practice run)
stow --verbose 2 . --simulate

# Really sync the dotfiles
stow --verbose 2 .
```

### Testing

Instead of managing an installation script, I have a test that I can run in
neovim.

The test checks that I have all the applications installed, and acts as a
reminder.

```vim
:checkhealth
```
