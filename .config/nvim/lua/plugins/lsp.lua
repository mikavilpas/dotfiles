-- https://www.lazyvim.org/plugins/lsp
---@type LazySpec
return {
  "neovim/nvim-lspconfig",

  dependencies = {
    {
      "folke/noice.nvim",
      opts = {
        lsp = {
          signature = {
            enabled = false,
          },
        },
      },
    },
    {
      "ray-x/lsp_signature.nvim",
      event = "VeryLazy",
      opts = {
        -- https://github.com/ray-x/lsp_signature.nvim?tab=readme-ov-file#full-configuration-with-default-values
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
          border = "rounded",
        },
      },
      config = function(_, opts)
        require("lsp_signature").setup(opts)
      end,
    },

    {
      "hrsh7th/cmp-cmdline",
      dependencies = { "hrsh7th/nvim-cmp", "hrsh7th/cmp-buffer" },
      event = { "InsertEnter", "CmdlineEnter" },
      config = function()
        -- https://github.com/hrsh7th/cmp-cmdline
        local cmp = require("cmp")
        -- `/` cmdline setup.
        cmp.setup.cmdline({ "/", "?" }, {
          mapping = cmp.mapping.preset.cmdline(),
          -- this fixes a bug
          -- https://github.com/hrsh7th/cmp-cmdline/issues/96#issuecomment-1705873476
          completion = { completeopt = "menu,menuone,noselect" },
          sources = {
            { name = "buffer" },
          },
        })

        -- `:` cmdline setup.
        cmp.setup.cmdline(":", {
          mapping = cmp.mapping.preset.cmdline(),
          -- this fixes this bug
          --
          -- first result auto-selected, but it doesn't search for the text in
          -- that result until I move selection down and back up again #96
          -- https://github.com/hrsh7th/cmp-cmdline/issues/96#issuecomment-1705873476
          completion = { completeopt = "menu,menuone,noselect" },
          sources = cmp.config.sources({
            { name = "path" },
          }, {
            {
              name = "cmdline",
              option = {
                ignore_cmds = { "Man", "!" },
              },
            },
          }),
        })
      end,
    },
    {
      "hrsh7th/nvim-cmp",
      ---@param opts cmp.ConfigSchema
      opts = function(_, opts)
        local cmp = require("cmp")

        ---@type cmp.ConfigSchema
        local new_options = {
          window = {
            completion = cmp.config.window.bordered({
              winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
            }),
            documentation = cmp.config.window.bordered({
              winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
            }),
          },
        }
        return vim.tbl_deep_extend("keep", new_options, opts)
      end,
    },
    {
      "marilari88/twoslash-queries.nvim",
      -- Usage
      -- Write a '//    ^?' placing the sign '^' under the variable to inspected
      opts = {

        -- https://github.com/marilari88/twoslash-queries.nvim?tab=readme-ov-file#config
        multi_line = true, -- to print types in multi line mode
        is_enabled = true, -- to keep disabled at startup and enable it on request with the TwoslashQueriesEnable
        highlight = "@comment.note", -- to set up a highlight group for the virtual text
      },
    },
  },

  init = function()
    -- configure keymaps here
    -- https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
    -- local keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- -- change a keymap
    -- keys[#keys + 1] = { "K", "<cmd>echo 'hello'<cr>" }
    -- -- disable a keymap
    -- keys[#keys + 1] = { "K", false }
    -- -- add a keymap
    -- keys[#keys + 1] = { "H", "<cmd>echo 'hello'<cr>" }
  end,

  opts = {

    servers = {
      tsserver = {
        on_attach = function(client, bufnr)
          require("twoslash-queries").attach(client, bufnr)
        end,
        settings = {
          scss = { lint = { enabled = false } },
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayVariableTypeHints = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHintsWhenTypeMatchesName = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayVariableTypeHints = true,

              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHintsWhenTypeMatchesName = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      },
    },
    inlay_hints = {
      enabled = true,
    },
    setup = {},
  },
}
