# https://fishshell.com/docs/current/tutorial.html

set -g fish_greeting ''
export XDG_CONFIG_HOME="$HOME/.config"

# https://typicode.github.io/husky/how-to.html#for-multiple-commands
export HUSKY=0

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

    # Commands to run in interactive sessions can go here
    atuin init fish | source
    starship init fish | source
    zoxide init fish | source

    abbr --add -- n nvim
    abbr --add -- j zi
    abbr --add -- dc "docker compose"
    abbr --add -- lg lazygit
    abbr --add -- - 'cd -'
    abbr --add -- ... 'cd ../../'
    abbr --add -- top btm

    # https://github.com/catppuccin/fish
    fish_config theme choose "Catppuccin Macchiato"

    # A modern, maintained replacement for ls
    # https://github.com/eza-community/eza
    abbr --add -- l "eza --oneline --all --long --no-user --icons=auto --no-permissions --time-style=long-iso"

    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    function w
        # https://github.com/watchexec/watchexec/issues/716
        watchexec --timings --no-process-group --project-origin . $argv
    end
    complete --command w --wraps watchexec

    function ww
        # like `w`, but restart running command on file changes
        # https://github.com/watchexec/watchexec/issues/716
        watchexec --on-busy-update=restart --timings --no-process-group --project-origin . $argv
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

    function klm
        cd /Users/mikavilpas/git/jelpp/jelpp-env
        fnm use
        npm run klm $argv
        cd -
        fnm use
    end
end
