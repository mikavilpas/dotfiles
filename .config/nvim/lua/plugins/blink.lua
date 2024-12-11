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
    snippets = {
      -- https://github.com/Saghen/blink.cmp?tab=readme-ov-file#luasnip
      expand = function(snippet)
        require("luasnip").lsp_expand(snippet)
      end,
      active = function(filter)
        if filter and filter.direction then
          return require("luasnip").jumpable(filter.direction)
        end
        return require("luasnip").in_snippet()
      end,
      jump = function(direction)
        require("luasnip").jump(direction)
      end,
    },
    signature = {
      enabled = true,
    },
    sources = {
      completion = {
        enabled_providers = {
          "lsp",
          "path",
          "snippets",
          "luasnip",
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
          score_offset = -999,
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
        draw = {
          treesitter = true,
        },
        max_height = 25,
      },
    },
  },
}
