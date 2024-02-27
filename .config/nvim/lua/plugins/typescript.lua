---@type LazySpec
return {
  {
    "pmizio/typescript-tools.nvim",
    ft = {
      "typescript",
      "javascript",
      "typescriptreact",
      "javascriptreact",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
      { "folke/neoconf.nvim", cmd = "Neoconf", dependencies = { "nvim-lspconfig" } },

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
      {
        -- Neovim plugin to automatic change normal string to template string
        -- in JS like languages
        -- https://github.com/axelvc/template-string.nvim
        "axelvc/template-string.nvim",
        config = true,
      },

      {
        -- https://github.com/ecosse3/nvim/blob/98f5d88971b8011701b8516ad5819a1fee470724/lua/config/plugins.lua#L474C2-L496C5
        "rcarriga/nvim-notify",
        init = function()
          local banned_messages = {
            "No information available",
          }

          ---@diagnostic disable-next-line: duplicate-set-field
          vim.notify = function(msg, ...)
            for _, banned in ipairs(banned_messages) do
              if msg == banned then
                return
              end
            end
            return require("notify")(msg, ...)
          end
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
