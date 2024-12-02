---@module "lazy"
---@module "fastaction"

-- https://www.lazyvim.org/plugins/lsp
---@type LazySpec
return {
  {
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

    opts = function(self, opts)
      -- configure keymaps here
      -- https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
      -- local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- -- change a keymap
      -- keys[#keys + 1] = { "K", "<cmd>echo 'hello'<cr>" }
      -- -- disable a keymap
      -- keys[#keys + 1] = { "K", false }
      -- -- add a keymap
      -- keys[#keys + 1] = { "H", "<cmd>echo 'hello'<cr>" }
      local keys = require("lazyvim.plugins.lsp.keymaps").get()

      keys[#keys + 1] = {
        -- make sure that goto definition and other lsp actions use the same split
        -- https://stackoverflow.com/questions/78842602/go-to-definition-in-current-window-if-split-windows-for-the-same-buffer#comment139062034_78842602
        -- https://www.lazyvim.org/extras/editor/fzf#nvim-lspconfig
        "gd",
        function()
          -- disable reuse_win to prevent the window from being reused
          require("telescope.builtin").lsp_definitions({ reuse_win = false })
        end,
      }

      opts = opts or {}
      opts.inlay_hints = { enabled = false }
      return opts
    end,
  },

  {
    -- Efficiency plugin designed to optimize code actions in Neovim
    -- https://github.com/Chaitanyabsprip/fastaction.nvim
    "Chaitanyabsprip/fastaction.nvim",
    event = "LspAttach",
    ---@type FastActionConfig
    opts = {},
    config = function(_, opts)
      require("fastaction").setup(opts)
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = {
        "<leader>ca",
        function()
          require("fastaction").code_action()
        end,
        mode = { "n" },
      }
      keys[#keys + 1] = {
        "<leader>ca",
        function()
          require("fastaction").range_code_action()
        end,
        mode = { "v" },
      }
    end,
  },
}
