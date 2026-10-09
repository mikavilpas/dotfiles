# exit if the last command succeeded (for one-off terminal tabs). Relies on
# `__last_cmd_status`, which is set by the fish_postexec handler in config.fish
function x
    if test "$__last_cmd_status" -eq 0
        exit
    else
        echo "Last command failed (status $__last_cmd_status), not exiting"
    end
end
