local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

---@type LazyConfig
local plugin_spec = {}

if os.getenv("NVIM") == nil then
  -- When running in normal mode
  plugin_spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import any extras modules here
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.coding.blink" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.toml" },
    -- { import = "lazyvim.plugins.extras.lang.tailwind" },
    { import = "lazyvim.plugins.extras.lang.git" },

    { import = "lazyvim.plugins.extras.coding.luasnip" },

    -- lsp symbol navigation for lualine. This shows where in the code structure
    -- you are - within functions, classes, etc - in the statusline.
    { import = "lazyvim.plugins.extras.editor.navic" },
    { import = "lazyvim.plugins.extras.ui.smear-cursor" },

    { import = "lazyvim.plugins.extras.linting.eslint" },
    { import = "lazyvim.plugins.extras.ui.treesitter-context", opts = {
      max_lines = 0,
    } },

    -- { import = "lazyvim.plugins.extras.dap.core" },
    -- { import = "lazyvim.plugins.extras.dap.nlua" },

    -- import/override with your plugins
    { import = "plugins" },
  }
else
  -- When running embedded in another process.
  -- I use this for quick edits and I want it to be extremely fast
  plugin_spec = {
    -- { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "fast-plugins" },
  }
end

require("lazy").setup(plugin_spec, {
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  ui = {
    border = "rounded",
  },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = false }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "matchit",
        "netrwPlugin",
        "matchparen",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- 📆 User Events
-- https://github.com/folke/lazy.nvim?tab=readme-ov-file#-user-events
-- The following user events will be triggered:
---@alias LazyCompatibleEvent
---| '"LazyDone"' when lazy has finished starting up and loaded your config
---| '"LazySync"' after running sync
---| '"LazyInstall"' after an install
---| '"LazyUpdate"' after an update
---| '"LazyClean"' after a clean
---| '"LazyCheck"' after checking for updates
---| '"LazyLog"' after running log
---| '"LazyLoad"' after loading a plugin. The data attribute will contain the plugin name.
---| '"LazySyncPre"' before running sync
---| '"LazyInstallPre"' before an install
---| '"LazyUpdatePre"' before an update
---| '"LazyCleanPre"' before a clean
---| '"LazyCheckPre"' before checking for updates
---| '"LazyLogPre"' before running log
---| '"LazyReload"' triggered by change detection after reloading plugin specs
---| '"VeryLazy"' triggered after LazyDone and processing VimEnter auto commands
---| '"LazyVimStarted"' triggered after UIEnter when require("lazy").stats().startuptime has been calculated. Useful to update the startuptime on your dashboard.
