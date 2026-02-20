# https://fishshell.com/docs/current/tutorial.html

set -g fish_greeting ''
export XDG_CONFIG_HOME="$HOME/.config"
export SKIM_DEFAULT_COMMAND="fd"
export SKIM_DEFAULT_OPTIONS="--height=40% --reverse"
export SKIM_CTRL_T_COMMAND="fd"
export SKIM_ALT_C_COMMAND="fd --type directory"

# https://typicode.github.io/husky/how-to.html#for-multiple-commands
export HUSKY=0
export EDITOR=nvim

fish_add_path $HOME/bin
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/go/bin/
fish_add_path /Users/mikavilpas/.local/share/bob/nvim-bin
fish_add_path $HOME/.luarocks/bin
fish_add_path $HOME/.local/share/bob/nvim-bin:$PATH
fish_add_path ~/.cargo/bin
fish_add_path $HOME/.local/share/nvim/mason/bin

# skip everything in CI because initialization will fail if all the required
# applications are not installed. They take a long time to install, and I don't
# have e2e tests for them anyway.
if status is-interactive && test -z "$CI"
    fish_vi_key_bindings
    mise activate fish | source

    # Commands to run in interactive sessions can go here
    #
    atuin init fish | source
    starship init fish | source
    zoxide init fish | source
    sk --shell-bindings --shell fish | source
    skim_key_bindings # activate sk key bindings like ctrl-t and alt-c

    abbr --add -- n nvim
    # interactive zoxide with skim (replaces `zi` which requires fzf)
    function j
        set result (zoxide query --list --score | sk --no-sort --no-multi)
        and set dir (string replace --regex '^\s*[0-9.]+ ' '' $result)
        and cd $dir
    end
    abbr --add -- dc "docker compose"
    abbr --add -- lg lazygit
    abbr --add -- - 'cd -'
    abbr --add -- ... 'cd ../../'
    abbr --add -- top btm
    abbr --add -- parallel rust-parallel

    # https://github.com/catppuccin/fish
    fish_config theme choose "Catppuccin Macchiato"

    # A modern, maintained replacement for ls
    # https://github.com/eza-community/eza
    abbr --add -- l "eza --oneline --all --long --no-user --icons=auto --no-permissions --time-style=long-iso"

    # open yazi, and cd to the directory it was closed in
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    # run the given command when files change in the current git repository
    function w
        # set the root of the git repository exactly to make sure watchexec is
        # able to match the ignore rules as expected
        set root (git rev-parse --show-toplevel 2>/dev/null)
        watchexec --timings --no-process-group --project-origin "$root" $argv
    end
    complete --command w --wraps watchexec

    # like `w`, but restart running command instantly on file changes
    function ww
        # like `w`, but restart running command on file changes
        # set the root of the git repository exactly to make sure watchexec is
        # able to match the ignore rules as expected
        set root (git rev-parse --show-toplevel 2>/dev/null)
        watchexec --on-busy-update=restart --timings --no-process-group --project-origin "$root" $argv
    end
    complete --command ww --wraps watchexec

    function battail
        set file $argv[1]
        set needle $argv[2]
        # https://github.com/sharkdp/bat?tab=readme-ov-file#tail--f
        if [ -z "$needle" ]
            tail -F $file | bat --style="plain" --color=always --paging=never --language log
        else
            tail -F $file | rg --line-buffered "$needle" | bat --style="plain" --paging=never --language log
        end
    end

    # pipe to this guy to colorize the output stream! 🪄
    # ya sub cd,hover | batrs
    abbr -a batrs 'bat --paging=never --language=rs --decorations=never'

    # show gitlab merge requests in a tree
    function mrs # "merge requests"
        glab mr list --author=@me --output=json | mika mrs-summary - --format=branches | glow --width=0
    end
end
