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
        ---@type vim.lsp.ClientConfig
        typos_lsp = {
          filetypes = {
            "lua",
            "typescript",
            "javascript",
            "typescriptreact",
            "javascriptreact",
            "rust",
            "markdown",
            "toml",
            "text", -- txt
          },

          init_options = {
            -- Custom config. Used together with any workspace config files, taking precedence for
            -- settings declared in both. Equivalent to the typos `--config` cli argument.
            -- config = '~/code/typos-lsp/crates/typos-lsp/tests/typos.toml',
            -- How typos are rendered in the editor, eg: as errors, warnings, information, or hints.
            -- Defaults to error.
            diagnosticSeverity = "HINT",
          },

          -- These settings are useful when I develop this LSP
          -- Logging level of the language server. Logs appear in :LspLog. Defaults to error.
          cmd_env = { RUST_LOG = "debug" },
          -- cmd = { "/Users/mikavilpas/git/typos-lsp/target/debug/typos-lsp" },
          cmd = { "typos-lsp" },
        },
      },
    },
  },
}
