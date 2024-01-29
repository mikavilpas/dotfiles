---@type LazySpec
return {
  "edluffy/specs.nvim",
  -- https://github.com/edluffy/specs.nvim
  -- Show where your cursor moves when jumping large distances (e.g between
  -- windows). Fast and lightweight, written completely in Lua.
  config = function()
    require("specs").setup({})
  end,
}
