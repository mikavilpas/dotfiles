---@type LazySpec
return {
  "nvim-lua/plenary.nvim",
  "neovim/nvim-lspconfig",

  {
    "rcarriga/nvim-notify",
    opts = {
      -- position notifications at the bottom, rather than at the top
      -- https://github.com/folke/noice.nvim/discussions/469#discussioncomment-9570150
      top_down = false,
    },
  },

  {
    -- Neovim plugin to automatic change normal string to template string
    -- in JS like languages
    -- https://github.com/axelvc/template-string.nvim
    "axelvc/template-string.nvim",
    ft = {
      "html",
      "typescript",
      "javascript",
      "typescriptreact",
      "javascriptreact",
      "vue",
      "svelte",
      "python",
    },
    config = true,
  },

  {
    "marilari88/twoslash-queries.nvim",
    event = "LspAttach",
    ft = {
      "typescript",
      "javascript",
      "typescriptreact",
      "javascriptreact",
    },
    -- Usage:
    -- Write a '//    ^?' placing the sign '^' under the variable to inspected
    opts = {
      -- https://github.com/marilari88/twoslash-queries.nvim?tab=readme-ov-file#config
      multi_line = true,
      is_enabled = true,
      highlight = "@comment.note",
    },
    config = function(_, opts)
      local tsq = require("twoslash-queries")
      tsq.setup(opts)

      require("lazyvim.util.lsp").on_attach(function(client, buffer)
        tsq.attach(client, buffer)
      end, "vtsls")
    end,
  },
}
