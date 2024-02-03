---@type LazySpec
return {
  "smoka7/hop.nvim",
  version = "*",
  event = "VeryLazy",
  opts = {},
  keys = {
    {
      "<leader>y",
      mode = { "n", "x", "o" },
      function()
        local hop = require("hop")
        hop.hint_lines_skip_whitespace({})
      end,
      desc = "Hop to line",
    },

    {
      "<leader><leader>",
      mode = { "n", "x", "o" },
      function()
        local hop = require("hop")
        hop.hint_char1({})
      end,
      desc = "Hop to given character",
    },
  },
}
