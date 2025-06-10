---@module "lazy"
---@type LazySpec
return {
  {
    "mistweaverco/kulala.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      ---@type TSConfig
      ---@diagnostic disable-next-line: missing-fields
      opts = {
        ensure_installed = { "http" },
      },
    },
    keys = {
      { "<leader>Rs", desc = "Send request" },
      { "<leader>Ra", desc = "Send all requests" },
      { "<leader>Rb", desc = "Open scratchpad" },
    },
    ft = { "http", "rest" },
    opts = {
      -- your configuration comes here
      global_keymaps = true,
    },
  },
}
