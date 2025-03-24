---@module "lazy"
---@type LazySpec
return {
  -- https://github.com/smoka7/hop.nvim
  "smoka7/hop.nvim",
  version = "*",
  opts = {
    -- remove the g and q key because catppuccin/nvim sets an underline highlight
    -- group. It's very hard to tell g and q apart.
    keys = ("asdghklqwertyuiopzxcvbnmfjäö"):gsub("g", ""):gsub("q", ""),
  },
  keys = {
    {
      "<leader>y",
      mode = { "n", "x", "o" },
      function()
        local hop = require("hop")
        ---@diagnostic disable-next-line: missing-fields
        hop.hint_lines({})
      end,
      desc = "Hop to line",
    },

    {
      "<leader><space>",
      mode = { "n", "x", "o" },
      function()
        local hop = require("hop")
        ---@diagnostic disable-next-line: missing-fields
        hop.hint_char1({})
      end,
      desc = "Hop to given character",
    },
  },
}
