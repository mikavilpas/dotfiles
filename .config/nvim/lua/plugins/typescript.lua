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
        -- Usage
        -- Write a '//    ^?' placing the sign '^' under the variable to inspected
        event = "LspAttach",
        keys = {
          { "<leader>at", "<cmd>TwoslashQueriesInspect<cr>", desc = "Show typescript type" },
        },
        config = function(_, opts)
          local palette = require("catppuccin.palettes.macchiato")
          local darken = require("catppuccin.utils.colors").darken
          vim.api.nvim_set_hl(0, "MikaTwoslashQueries", {
            fg = palette.base,
            bg = darken(palette.blue, 0.8),
          })
          opts.multi_line = true
          opts.highlight = "MikaTwoslashQueries"
          opts.is_enabled = true

          require("twoslash-queries").setup(opts)
        end,
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
