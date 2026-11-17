---@module "lazy"
---@type LazySpec
return {
  {
    -- NOTE the defaults for LazyVim are here https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua

    "nvim-treesitter/nvim-treesitter",
    init = function()
      -- jsonc was dropped from nvim-treesitter main branch; reuse the json
      -- parser so jsonc filetype still gets highlighting
      vim.treesitter.language.register("json", "jsonc")

      -- neovim detects ~/.aws/config and similar files as confini, which has
      -- no parser of its own. The ini parser highlights it.
      vim.treesitter.language.register("ini", "confini")
    end,
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      -- add more treesitter parsers
      ensure_installed = {
        "bash",
        "css",
        "fish",
        "html",
        "ini",
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
  },

  {
    "mikavilpas/incr.nvim",
    version = "*",
    opts = {
      incr_key = "<C-space>",
      decr_key = "<backspace>",
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      mode = "topline", -- Line used to calculate context. Choices: 'cursor', 'topline'
    },
  },
}
