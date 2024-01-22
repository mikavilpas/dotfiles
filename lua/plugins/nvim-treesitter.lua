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
      "query",
      "regex",
      "tsx",
      "typescript",
      "yaml",
    },
  },
}
