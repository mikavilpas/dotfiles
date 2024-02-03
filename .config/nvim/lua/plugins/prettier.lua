---@type LazyPluginSpec
return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    formatters_by_ft = {
      toml = { "prettier" },
    },
  },
}
