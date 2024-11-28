---@module "lazy"
---@module "snacks"
---@type LazySpec
return {
  {
    -- With the release of Neovim 0.6 we were given the start of extensible
    -- core UI hooks (vim.ui.select and vim.ui.input). They exist to allow
    -- plugin authors to override them with improvements upon the default
    -- behavior, so that's exactly what we're going to do.
    -- https://github.com/blob42/dressing.nvim
    "stevearc/dressing.nvim",
    opts = { input = { insert_only = false } },
  },
  {
    -- 🍿 A collection of small QoL plugins for Neovim
    -- https://github.com/folke/snacks.nvim
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      notifier = {
        -- position notifications at the bottom, rather than at the top
        top_down = false,
      },
    },
  },
  {
    "sphamba/smear-cursor.nvim",
    -- https://github.com/sphamba/smear-cursor.nvim
    opts = {
      -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
      -- Smears will blend better on all backgrounds.
      legacy_computing_symbols_support = true,
    },
  },
}
