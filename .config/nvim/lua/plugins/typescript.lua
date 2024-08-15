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
    "pmizio/typescript-tools.nvim",
    ft = {
      "typescript",
      "javascript",
      "typescriptreact",
      "javascriptreact",
    },
    dependencies = {
      {
        "marilari88/twoslash-queries.nvim",
        event = "LspAttach",
        keys = {
          { "<leader>at", "<cmd>TwoslashQueriesInspect<cr>", desc = "Show typescript type" },
        },
        -- Usage
        -- Write a '//    ^?' placing the sign '^' under the variable to inspected
        opts = {
          -- https://github.com/marilari88/twoslash-queries.nvim?tab=readme-ov-file#config
          multi_line = true,
          is_enabled = true,
          highlight = "@comment.note", -- to set up a highlight group for the virtual text
        },
      },
    },

    opts = {
      on_attach = function(client, bufnr)
        require("twoslash-queries").attach(client, bufnr)
      end,

      settings = {
        expose_as_code_action = "all",

        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  },
}
