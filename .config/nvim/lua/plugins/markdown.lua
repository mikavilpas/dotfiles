---@module "render-markdown"
---@module "lazy"

---@type LazySpec
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = function(_, formats)
      return vim.list_extend(formats, { "gitcommit" })
    end,
    ---@type render.md.Config
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      file_types = { "gitcommit", "markdown" },
      ---@diagnostic disable-next-line: missing-fields
      completions = {
        lsp = { enabled = true },
      },
      ---@diagnostic disable-next-line: missing-fields
      latex = {
        enabled = false,
      },
    },
    config = function()
      -- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/141
      require("luasnip").filetype_extend("gitcommit", { "markdown" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      ---@type table<string, vim.lsp.Config>
      servers = {
        -- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/rumdl.lua
        -- https://github.com/rvben/rumdl/blob/main/docs/lsp.md
        rumdl = {
          -- this is installed with mise, so don't install another one via mason
          -- https://www.lazyvim.org/plugins/lsp#nvim-lspconfig
          mason = false,
        },
      },
    },
  },
}
