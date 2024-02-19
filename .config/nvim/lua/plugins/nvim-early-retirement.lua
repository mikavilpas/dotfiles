---@type LazySpec
return {
  -- https://github.com/chrisgrieser/nvim-early-retirement/blob/main/lua/early-retirement.lua
  "chrisgrieser/nvim-early-retirement",
  opts = {
    retirementAgeMins = 5,
  },
  config = true,
  event = "VeryLazy",
}
