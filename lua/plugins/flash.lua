return {
  "folke/flash.nvim",
  event = "VeryLazy",
  keys = {
    -- enable substitute with (normal) s
    { "s", mode = { "n", "x", "o" }, false },
    -- enable surround with (visual) S
    { "S", mode = { "n", "x", "o" }, false },
  },
  -- @type Flash.Config
  config = function() end,
}
