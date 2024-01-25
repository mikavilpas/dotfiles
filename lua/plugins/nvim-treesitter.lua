---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- add more treesitter parsers
    ensure_installed = {
      "bash",
      "html",
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
}
