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

    opts = {
      inlay_hints = { enabled = false },
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
  },

  {
    -- LSP signature hint as you type
    -- https://github.com/ray-x/lsp_signature.nvim
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      -- https://github.com/ray-x/lsp_signature.nvim?tab=readme-ov-file#full-configuration-with-default-values
      bind = true, -- This is mandatory, otherwise border config won't get registered.
      max_height = 999,
      doc_lines = 999,
      hi_parameter = "@text.note",
      hint_prefix = "🤔 ",
      handler_opts = { border = "rounded" },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            vim.notify("LSP client not found: " .. args.data.client_id, "error")
            return
          end
          if vim.tbl_contains({ "null-ls" }, client.name) then -- blacklist lsp
            return
          end
          require("lsp_signature").on_attach(opts, bufnr)
        end,
      })
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
