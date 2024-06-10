---@type LazySpec
return {
  -- https://github.com/fedepujol/move.nvim
  "fedepujol/move.nvim",
  lazy = true,
  keys = {
    { "K", ":MoveBlock(-1)<CR>", mode = { "v" }, silent = true },
    { "J", ":MoveBlock(1)<CR>", mode = { "v" }, silent = true },
  },
  config = function()
    require("move").setup({})
  end,
}
