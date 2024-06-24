source ~/dotfiles/.wezterm.sh

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/go/bin/:/usr/local/bin:$PATH:$HOME/Library/Android/sdk/platform-tools
export PATH=$PATH:$HOME/.luarocks/bin:

export LANG=fi_FI.UTF-8
export LC_ALL=fi_FI.UTF-8

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# change the default config directory on osx from ~/Library/Application Support/
export XDG_CONFIG_HOME="$HOME/.config"

set editing-mode vi
set blink-matching-paren on

# https://youtu.be/ud7YxC33Z3w?t=698
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# https://dev.to/thraizz/fix-slow-zsh-startup-due-to-nvm-408k
zstyle ':omz:plugins:nvm' lazy yes

# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/z
# https://github.com/agkozak/zsh-z
plugins=(git httpie npm z fd nvm)

# User configuration

source $ZSH/oh-my-zsh.sh

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'
export VISUAL="nvr --remote-wait"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# needs to be the last command, otherwise ctrl+r doesn*t work
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#if [ -f bindkey ]; then
bindkey -v
bindkey '^e' autosuggest-accept
#fi;

eval "$(starship init zsh)"

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

alias dc="docker-compose"
function w() {
  watchexec --timings --project-origin . $@
}

# A modern, maintained replacement for ls
# https://github.com/eza-community/eza
alias l="eza --oneline --all --long --no-user --icons=auto --no-permissions --time-style=long-iso"

# jelpp-env stuff
# alias klm="cd /Users/mikavilpas/git/jelpp/jelpp-env; npm run klm --"
klm() {
  (cd /Users/mikavilpas/git/jelpp/jelpp-env && nvm use && npm run klm "$@")
}


#source ~/bin/aws-profile.zsh
# fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"

# a nice preview command for ctrl_t
# https://github.com/sharkdp/bat/issues/357#issuecomment-555971886
export FZF_PREVIEW_COMMAND="bat --style=numbers,changes --wrap never --color always {} || cat {} || tree -C {}"
export FZF_CTRL_T_OPTS="--min-height 30 --preview-window right:60% --preview-window noborder --preview '($FZF_PREVIEW_COMMAND) 2> /dev/null'"

eval "$(zoxide init zsh)"export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export RUSTC_WRAPPER=/opt/homebrew/bin/sccache

function battail() {
  local file=$1
  local needle=$2
  # https://github.com/sharkdp/bat?tab=readme-ov-file#tail--f
  if [ -z "$needle" ]; then
    tail -F $file | bat --style="plain" --color=always --paging=never --language log
  else
    tail -F $file | rg --line-buffered "$needle" | bat --style="plain" --paging=never --language log
  fi
}

# j for "jump"
alias j="zi"

function isDarkMode() {
  defaults read -globalDomain AppleInterfaceStyle &> /dev/null
  return $?
}

alias lg="lazygit"

function my_git_grep_history() {
  needle=$1
  git log -S "$1" --oneline --color=always |\
    fzf --multi --ansi --preview="git show --color=always {1} | bat --style=numbers,changes --color=always"
}

# yazi integration (terminal file manager)
# https://yazi-rs.github.io/docs/quick-start
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

alias y="yy"

my_git_commit_messages() {
  local start_commit_inclusive=$1
  git log "$start_commit_inclusive^..HEAD"
}

# Global aliases for automatically highlighting help messages
# (these don't always work. E.g. `docker-compose --help build` doesn't work)
# https://github.com/sharkdp/bat?tab=readme-ov-file#highlighting---help-messages
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# tabtab source for packages
# uninstall by removing these lines
# [[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# Cool syntax highlighting for zsh, almost like the fish shell
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
