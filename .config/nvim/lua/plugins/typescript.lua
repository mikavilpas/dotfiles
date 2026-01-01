---@module "lazy"
---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      ---@type table<string, vim.lsp.Config>
      servers = {
        oxlint = {
          -- opt in to early changes from this PR, these can be removed when it
          -- gets merged
          -- https://github.com/neovim/nvim-lspconfig/pull/4242
          cmd = { "oxlint", "--lsp" },
          on_attach = function(client, bufnr)
            vim.api.nvim_buf_create_user_command(bufnr, "LspOxlintFixAll", function()
              client:exec_cmd({
                title = "Apply Oxlint automatic fixes",
                command = "oxc.fixAll",
                arguments = { { uri = vim.uri_from_bufnr(bufnr) } },
              })
            end, {
              desc = "Apply Oxlint automatic fixes",
            })
          end,
          mason = false,
        },
        tsgo = {
          on_attach = function(client, bufnr)
            require("twoslash-queries").attach(client, bufnr)
          end,

          -- this is installed with mise, so don't install another one via mason
          -- https://www.lazyvim.org/plugins/lsp#nvim-lspconfig
          mason = false,
        },
        eslint = {
          settings = {
            -- Fix https://github.com/un-ts/eslint-plugin-import-x starting
            -- resolution from an incorrect folder. This might make it so that
            -- the project needs to be configured with an eslint config file in
            -- the workspace root.
            workingDirectories = { mode = "location" },
            workingDirectory = { mode = "location" },
          },
        },
      },
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
}
