---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- add more treesitter parsers
    ensure_installed = {
      "bash",
      "html",
      "scss",
      "javascript",
      "json",
      "lua",
      "make",
      "markdown",
      "markdown_inline",
      "sql",
      "query",
      "regex",
      "tsx",
      "typescript",
      "yaml",
    },
  },

  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)

    -- Custom filetype detection for .css files
    vim.cmd([[
        autocmd BufRead,BufNewFile *.css set filetype=scss
      ]])
  end,
}
