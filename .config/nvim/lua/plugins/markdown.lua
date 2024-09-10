---@module "render-markdown"
---@module "lazy"

---@type LazySpec

return {
  "MeanderingProgrammer/markdown.nvim",
  ft = function(_, ft)
    vim.list_extend(ft, { "gitcommit" })
  end,
  ---@param opts render.md.Config
  opts = function(_, opts)
    -- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/141
    vim.list_extend(opts.file_types, { "gitcommit" })
    require("luasnip").filetype_extend("gitcommit", { "markdown" })
  end,
}
