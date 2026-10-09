# like `w`, but restart running command instantly on file changes
function ww --wraps watchexec
    # set the root of the git repository exactly to make sure watchexec is
    # able to match the ignore rules as expected
    set root (git rev-parse --show-toplevel 2>/dev/null)
    watchexec --on-busy-update=restart --interactive --timings --wrap-process=none --project-origin "$root" $argv
end
