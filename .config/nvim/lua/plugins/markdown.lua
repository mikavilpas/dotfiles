---@module "render-markdown"
---@module "lazy"

---@type LazySpec
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = function(_, ft)
    return vim.list_extend(ft, { "gitcommit" })
  end,
  ---@param opts render.md.Config
  opts = function(_, opts)
    -- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/141
    opts.file_types = opts.file_types or {}
    vim.list_extend(opts.file_types, { "gitcommit" })
    require("luasnip").filetype_extend("gitcommit", { "markdown" })

    return opts
  end,
}
