return {
  "smoka7/hop.nvim",
  version = "*",
  opts = {},
  keys = {
    {
      "<leader>y",
      mode = { "n", "x", "o" },
      function()
        local hop = require("hop")
        hop.hint_lines_skip_whitespace({})
      end,
    },
  },
}
