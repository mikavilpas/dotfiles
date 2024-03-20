---@type LazySpec
return {
  -- https://github.com/smoka7/hop.nvim
  "smoka7/hop.nvim",
  version = "*",
  opts = {
    -- remove the g and q keys because catppuccin/nvim sets an underline highlight
    -- group. It's very hard to tell g and q apart.
    keys = ("asdghklqwertyuiopzxcvbnmfjäö"):gsub("g", ""):gsub("q", ""),
  },
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
