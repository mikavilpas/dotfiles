return {
  "folke/flash.nvim",
  event = "VeryLazy",
  keys = {
    -- enable substitute
    { "s", mode = { "n", "x", "o" }, false },
    -- enable surround
    { "S", mode = { "n", "x", "o" }, false },
  },
  -- @type Flash.Config
  config = function() end,
}
