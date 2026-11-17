# run the given command when files change in the current git repository
function w --wraps watchexec
    # set the root of the git repository exactly to make sure watchexec is
    # able to match the ignore rules as expected
    set root (git rev-parse --show-toplevel 2>/dev/null)
    watchexec --timings --interactive --wrap-process=none --project-origin "$root" $argv
end
