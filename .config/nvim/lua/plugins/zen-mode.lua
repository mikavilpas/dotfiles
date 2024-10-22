-- https://github.com/folke/zen-mode.nvim
---@module "lazy"
---@type LazySpec
return {
  "folke/zen-mode.nvim",
  dependencies = { "folke/twilight.nvim" },
  keys = {
    { "<leader>uz", ":ZenMode<CR>", silent = true, noremap = true },
  },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below

    plugins = {
      wezterm = {
        font = "+5",
        enabled = true,
      },
    },
  },
}
