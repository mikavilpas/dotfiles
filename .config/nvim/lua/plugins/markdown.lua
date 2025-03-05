---@module "render-markdown"
---@module "lazy"

---@type LazySpec
return {
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
}
