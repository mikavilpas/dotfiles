---@module "lazy"
---@type LazySpec
return {
  -- NOTE the defaults for LazyVim are here https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua

  "nvim-treesitter/nvim-treesitter",
  ---@type TSConfig
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    -- add more treesitter parsers
    ensure_installed = {
      "bash",
      "css",
      "html",
      "javascript",
      "json",
      "just",
      "lua",
      "make",
      "markdown",
      "markdown_inline",
      "mermaid",
      "query",
      "regex",
      "scheme",
      "scss",
      "sql",
      "tsx",
      "typescript",
      "yaml",
    },

    autotag = {
      enable = true,
    },
  },

  ---@param opts TSConfig
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)

    -- Custom filetype detection for .css files
    -- vim.cmd([[
    --     autocmd BufRead,BufNewFile *.css set filetype=scss
    -- ]])
  end,
}
