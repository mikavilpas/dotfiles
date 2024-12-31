-- until blink is published https://www.lazyvim.org/extras/coding/blink#options
vim.g.lazyvim_blink_main = true

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

  config = function(_, opts)
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    local my_opts = {
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
        default = {
          "lsp",
          "path",
          -- "snippets",
          "luasnip",
          "buffer",
          "ripgrep",
        },
        cmdline = {
          -- disable cmdline completion for now
        },
        providers = {
          path = { score_offset = 999 },
          lsp = { score_offset = 99 },
          buffer = { score_offset = 9 },
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
            score_offset = -999,
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {},
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                item.labelDetails = {
                  description = "(rg)",
                }
              end
              return items
            end,
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
            treesitter = { "lsp" },
          },
          max_height = 25,
        },
      },
    }
    opts = vim.tbl_deep_extend("force", opts, my_opts)

    -- workaround LazyVim not supporting the latest schema yet
    opts.sources.compat = nil
    require("blink.cmp").setup(opts)
  end,
}
