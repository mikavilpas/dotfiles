---@type LazySpec
return {
  "pmizio/typescript-tools.nvim",
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
  },

  opts = {
    on_attach = function(client, bufnr)
      require("twoslash-queries").attach(client, bufnr)
    end,

    settings = {
      expose_as_code_action = "all",
    },
  },
}
