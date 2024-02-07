---@type LazySpec
return {
  -- Dim inactive windows in Neovim using window-local highlight namespaces.
  -- https://github.com/levouh/tint.nvim
  "levouh/tint.nvim",
  event = "VeryLazy",

  config = function(_)
    require("tint").setup({})
  end,
}
