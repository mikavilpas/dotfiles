---@diagnostic disable: missing-fields
---@module "lazy"
---@type LazySpec
return {
  -- ../../../../../.local/share/nvim/lazy/blink.cmp/lua/blink/cmp/init.lua
  -- ../../../../../.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/coding/blink.lua
  "saghen/blink.cmp",
  version = false,
  -- dir = "~/git/blink.cmp/",
  build = "cargo build --release",
  dependencies = {
    "rafamadriz/friendly-snippets",
    {
      -- ~/.local/share/nvim/lazy/blink-ripgrep.nvim/lua/blink-ripgrep/init.lua
      "mikavilpas/blink-ripgrep.nvim",
      -- dir = "~/git/blink-ripgrep.nvim/",
    },
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
          name = "path",
          score_offset = 999,
        },
        lsp = {
          name = "lsp",
          score_offset = 99,
        },
        buffer = {
          name = "buffer",
          score_offset = 9,
        },
        ripgrep = {
          module = "blink-ripgrep",
          name = "Ripgrep",
          ---@module "blink-ripgrep"
          ---@type blink-ripgrep.Options
          opts = {},
        },
      },
    },
    fuzzy = {
      prebuilt_binaries = {
        download = false,
      },
    },
    completion = {
      documentation = {
        window = {
          desired_min_height = 30,
          max_width = 120,
        },
        auto_show = true,
      },
      menu = {
        max_height = 25,
      },
    },
  },
}
