---@module "lazy"
---@module "blink-cmp-rg"
---@type LazySpec
return {
  -- ../../../../../.local/share/nvim/lazy/blink.cmp/lua/blink/cmp/init.lua
  "saghen/blink.cmp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    {
      -- ../../../../../.local/share/nvim/lazy/blink-cmp-rg.nvim/lua/blink-cmp-rg/init.lua
      "mikavilpas/blink-cmp-rg.nvim",
      -- dir = "~/git/blink-cmp-rg.nvim/",
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
          score_offset = 100,
        },
        lsp = {
          score_offset = 99,
        },
        ripgrep = {
          module = "blink-cmp-rg",
          name = "Ripgrep",
          ---@type blink-cmp-rg.Options
          opts = {
            get_command = function(_, prefix)
              local root = require("my-nvim-micro-plugins.main").find_project_root()
              return {
                "rg",
                "--no-config",
                "--json",
                "--word-regexp",
                "--ignore-case",
                "--",
                prefix .. "[\\w_-]+",
                root or vim.fn.getcwd(),
              }
            end,
          },
        },
      },
    },
    windows = {
      autocomplete = {
        max_height = 25,
      },
    },
  },
}
