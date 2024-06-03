-- This is this file before it was reverted to using prettier instead of prettierd
-- https://github.com/LazyVim/LazyVim/blob/91126b9896bebcea9a21bce43be4e613e7607164/lua/lazyvim/plugins/extras/formatting/prettier.lua
-- https://github.com/LazyVim/LazyVim/commit/57b504b9e8ae95c294c17e97e7f017f6f802ebbc?diff=split&w=0
---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "prettierd")
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.prettierd)
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        ["javascript"] = { { "prettierd" } },
        ["javascriptreact"] = { { "prettierd" } },
        ["typescript"] = { { "prettierd" } },
        ["typescriptreact"] = { { "prettierd" } },
        ["vue"] = { { "prettierd" } },
        ["css"] = { { "prettierd" } },
        ["scss"] = { { "prettierd" } },
        ["less"] = { { "prettierd" } },
        ["html"] = { { "prettierd" } },
        ["json"] = { { "prettierd" } },
        ["jsonc"] = { { "prettierd" } },
        ["yaml"] = { { "prettierd" } },
        ["markdown"] = { { "prettierd" } },
        ["markdown.mdx"] = { { "prettierd" } },
        ["graphql"] = { { "prettierd" } },
        ["handlebars"] = { { "prettierd" } },
        -- currently prettier-plugin-toml is not configurable, and I don't like
        -- the default formatting
        -- ["toml"] = { "prettier" },
      },
    },
  },
}
