-- typos
-- Source code spell checker
--
-- Finds and corrects spelling mistakes among source code:
--
-- Fast enough to run on monorepos
-- Low false positives so you can run on PRs
--
-- https://github.com/crate-ci/typos?tab=readme-ov-file
-- https://github.com/tekumara/typos-lsp
---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "typos-lsp",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        typos_lsp = {},
      },
    },
  },
}
