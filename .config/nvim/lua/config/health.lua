-- checkhealth implementation for all the cli tools that I depend on

return {
  check = function()
    vim.health.start("my-cli-tools")

    local function check(application_name)
      if vim.fn.executable(application_name) ~= 1 then
        vim.health.warn(application_name .. " not found on PATH")
      end
    end

    -- "find" replacement with a well-designed command-line interface
    check("fd")

    -- fzf - a command-line fuzzy finder
    check("fzf")

    -- zf - a commandline fuzzy finder that prioritizes matches on filenames
    check("zf")

    -- utility for printing the resolved path of a file, used for e.g. relative
    -- file resolution
    check("grealpath")

    -- jq - a lightweight and flexible command-line JSON processor
    check("jq")

    -- lazygit - simple terminal UI for git commands
    check("lazygit")

    -- a markdown terminal slideshow tool
    check("presenterm")

    -- ripgrep - recursively searches directories for a regex pattern
    check("rg")

    -- a smarter cd command
    check("zoxide")

    -- 🦀 Painless compression and decompression in the terminal
    check("ouch")

    -- 🦀 Source code spell checker
    check("typos")

    -- 🦀 Atuin replaces your existing shell history with a SQLite database,
    -- and records additional context for your commands. Additionally, it
    -- provides optional and fully encrypted synchronisation of your history
    -- between machines, via an Atuin server.
    -- https://github.com/atuinsh/atuin
    check("atuin")

    -- 🦀 Yet another cross-platform graphical process/system monitor.
    -- https://github.com/ClementTsang/bottom
    check("btm")

    -- 🦀 Sccache is a ccache-like tool. It is used as a compiler wrapper and
    -- avoids compilation when possible. Sccache has the capability to utilize
    -- caching in remote storage environments, including various cloud storage
    -- options, or alternatively, in local storage.
    --
    -- https://github.com/mozilla/sccache
    check("sccache")

    -- fnm (🚀 Fast and simple Node.js version manager, built in Rust)
    -- https://github.com/Schniz/fnm
    check("fnm")

    vim.health.ok("my-cli-tools")
  end,
}
