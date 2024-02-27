-- https://www.lazyvim.org/plugins/lsp
---@type LazySpec
return {
  -- nvim-lspconfig is a collection of community-contributed configurations for the
  -- built-in language server client in Nvim core. This plugin provides four
  -- primary functionalities:
  --
  --  - default launch commands, initialization options, and settings for each
  --    server
  --  - a root directory resolver which attempts to detect the root of your project
  --  - an autocommand mapping that either launches a new language server or
  --    attempts to attach a language server to each opened buffer if it falls
  --    under a tracked project
  --  - utility commands such as LspInfo, LspStart, LspStop, and LspRestart for
  --    managing language server instances
  --
  -- nvim-lspconfig is not required to use the builtin Nvim |lsp| client, it is
  -- just a convenience layer.
  --
  "neovim/nvim-lspconfig",

  dependencies = {
    {
      "folke/noice.nvim",
      ---@type NoiceConfig
      opts = {
        ---@type NoicePresets
        presets = {
          lsp_doc_border = true,

          -- https://github.com/nicknisi/dotfiles/blob/3a394aa71ab034502e8866a442be22d78f1556ee/config/nvim/lua/plugins/noice.lua#L7
          long_message_to_split = true, -- long messages will be sent to a split
          cmdline_output_to_split = true,
        },
        lsp = {
          signature = {
            enabled = false,
          },
        },

        routes = {
          -- disable some annoying messages popping up. I hate them!
          -- stylua: ignore start
          { view = "split", filter = { event = "msg_show", min_height = 3 } },
          { filter = { find = "No information available" }, opts = { stop = true } },
          { filter = { find = "fewer lines;" }, opts = { skip = true } },
          { filter = { find = "more line;" }, opts = { skip = true } },
          { filter = { find = "more lines;" }, opts = { skip = true } },
          { filter = { find = "less;" }, opts = { skip = true } },
          { filter = { find = "change;" }, opts = { skip = true } },
          { filter = { find = "changes;" }, opts = { skip = true } },
          { filter = { find = "indent" }, opts = { skip = true } },
          { filter = { find = "move" }, opts = { skip = true } },

          -- Disable "file_path" AMOUNT_OF_LINESL, AMOUNT_OF_BYTESB message
          -- https://github.com/KoalaVim/KoalaVim/blob/e4649e74a1838e6a4a1a55a72e58280064bb909c/lua/KoalaVim/misc/noice_routes.lua#L6
          { filter = { event = "msg_show", kind = "", find = '"[%w%p]+" %d+L, %d+B' }, opts = { skip = true } },

          -- Disable "search messages"
          { filter = { event = "msg_show", kind = "wmsg", find = "search hit BOTTOM, continuing at TOP", }, opts = { skip = true }, },
          { filter = { event = "msg_show", kind = "wmsg", find = "search hit TOP, continuing at BOTTOM" }, opts = { skip = true }, },

          -- Disable "redo/undo" messages
          { filter = { event = "msg_show", kind = "lua_error", find = "more line" }, opts = { skip = true } },
          { filter = { event = "msg_show", kind = "lua_error", find = "fewer line" }, opts = { skip = true } },
          { filter = { event = "msg_show", kind = "lua_error", find = "line less" }, opts = { skip = true } },
          { filter = { event = "msg_show", kind = "lua_error", find = "change;" }, opts = { skip = true } },
          { filter = { event = "msg_show", kind = "", find = "more line" }, opts = { skip = true } },
          { filter = { event = "msg_show", kind = "", find = "fewer line" }, opts = { skip = true } },
          { filter = { event = "msg_show", kind = "", find = "line less" }, opts = { skip = true } },
          { filter = { event = "msg_show", kind = "", find = "change;" }, opts = { skip = true } },
          -- stylua: ignore end
        },
      },
    },
    {
      "ray-x/lsp_signature.nvim",
      event = "VeryLazy",
      opts = {
        -- https://github.com/ray-x/lsp_signature.nvim?tab=readme-ov-file#full-configuration-with-default-values
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = { border = "rounded" },
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
        -- `/` and '?' cmdline setup.
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

    ---@type lspconfig.options
    servers = {
      tsserver = {
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
  },
}
