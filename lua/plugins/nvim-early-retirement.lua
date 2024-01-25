---@type LazySpec
return {
  -- https://github.com/chrisgrieser/nvim-early-retirement/blob/main/lua/early-retirement.lua
  "chrisgrieser/nvim-early-retirement",
  config = {
    retirementAgeMins = 5,
  },
  event = "VeryLazy",
}
