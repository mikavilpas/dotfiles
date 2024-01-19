---@type LazySpec
return {
  -- https://github.com/levouh/tint.nvim
  "levouh/tint.nvim",
  event = "VeryLazy",

  config = function(_)
    require("tint").setup({})
  end,
}
