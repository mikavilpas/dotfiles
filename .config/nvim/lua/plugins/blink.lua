return {
  "saghen/blink.cmp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "niuiic/blink-cmp-rg.nvim",
  },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    sources = {
      completion = {
        enabled_providers = {
          "lsp",
          "path",
          "snippets",
          "buffer",
          "ripgrep",
        },
      },
      providers = {
        path = {
          score_offset = 100,
        },
        lsp = {
          score_offset = 99,
        },
        ripgrep = {
          module = "blink-cmp-rg",
          name = "Ripgrep",
        },
      },
    },
  },
}
