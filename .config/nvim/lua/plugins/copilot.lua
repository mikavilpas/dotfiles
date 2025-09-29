---@module "lazy"
---@type LazySpec
return {
  {
    "zbirenbaum/copilot.lua",
    enabled = false,
    -- ../../../../../.local/share/nvim/lazy/copilot.lua/lua/copilot/config.lua
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      -- https://github.com/zbirenbaum/copilot.lua?tab=readme-ov-file#setup-and-configuration
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept_word = "<c-l>",
        },
      },
      debounce = 300, --ms
      filetypes = {
        markdown = true,
        yaml = true,
        gitcommit = true,
        help = true,
      },
    },

    config = function(_, opts)
      local copilot = require("copilot")
      copilot.setup(opts)

      vim.keymap.set("i", "<S-down>", function()
        require("copilot.suggestion").accept_line()

        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, true, true), "n", true)
      end)

      vim.keymap.set("i", "<S-right>", function()
        require("copilot.suggestion").accept()
      end)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = {
        "<S-right>",
        mode = { "i" },
        function()
          -- vim.lsp.inline_completion.select({ count = 1 })
          LazyVim.cmp.actions.ai_accept()

          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, true, true), "n", true)
        end,
      }
    end,
  },

  {
    "folke/sidekick.nvim",
    keys = {
      -- https://www.lazyvim.org/extras/ai/sidekick
      { "<tab>", false },
      { "ä", LazyVim.cmp.map({ "ai_nes" }, "<tab>"), mode = { "n" }, expr = true },
    },
  },
}
