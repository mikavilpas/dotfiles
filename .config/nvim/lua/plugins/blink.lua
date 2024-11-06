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
          score_offset = 100,
        },
        lsp = {
          score_offset = 99,
        },
        ripgrep = {
          module = "blink-ripgrep",
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
