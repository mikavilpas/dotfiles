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
      version = "*",
      -- dir = "~/git/blink-ripgrep.nvim/",
    },
  },

  config = function(_, opts)
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    local my_opts = {
      keymap = {
        ["<C-f>"] = {
          function(cmp)
            return cmp.select_next({ jump_by = "source_id" })
          end,
          "select_next",
        },
        ["<C-b>"] = {
          function(cmp)
            return cmp.select_prev({ jump_by = "source_id" })
          end,
          "select_prev",
        },
      },
      signature = {
        enabled = true,
      },
      snippets = {
        preset = "luasnip",
      },
      sources = {
        default = {
          "lsp",
          "path",
          "snippets",
          "buffer",
          "ripgrep",
        },
        -- cmdline = {
        --   -- disable cmdline completion for now
        -- },
        providers = {
          path = {
            score_offset = 9,
            ---@type blink.cmp.PathOpts
            opts = {
              show_hidden_files_by_default = true,
            },
          },
          snippets = {
            score_offset = -100,
          },
          lsp = {
            score_offset = 8,
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                if item.client_name == "typescript-tools" then
                  -- when the completion adds an import, show the source
                  -- https://github.com/Saghen/blink.cmp/issues/1870#issuecomment-2956622232
                  local source = vim.tbl_get(item, "data", "entryNames", 1, "source")
                  if source then
                    item.labelDetails = item.labelDetails or {}
                    item.labelDetails.description = source
                  end
                end
              end

              return items
            end,
          },
          buffer = { score_offset = 5 },
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
            score_offset = -8,
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {
              toggles = {
                on_off = "<leader>tg",
                debug = "<leader>td",
              },
              backend = {
                use = "gitgrep-or-ripgrep",
              },
            },
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
        implementation = "rust",
        sorts = {
          "exact",
          "score",
          "sort_text",
        },
        prebuilt_binaries = {
          download = false,
        },
      },
      completion = {
        documentation = {
          window = {
            desired_min_height = 30,
            max_width = 120,
            max_height = 999,
            border = "rounded",
          },
          auto_show = true,
        },
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
          max_height = 30,
        },
      },
    }
    opts = vim.tbl_deep_extend("force", opts, my_opts)

    -- workaround LazyVim not supporting the latest schema yet
    opts.sources.compat = nil
    require("blink.cmp").setup(opts)
  end,
}
