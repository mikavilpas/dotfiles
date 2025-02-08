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
      scope = {
        edge = false,
      },
      notifier = {
        -- position notifications at the bottom, rather than at the top
        top_down = false,
      },

      picker = {
        win = {
          input = {
            keys = {
              -- my-nvim-micro-plugins defines this
              ["<C-y>"] = { "my_copy_relative_path", mode = { "n", "i" } },
            },
          },
        },
      },
    },
  },
}
