---@return LazySpec
return {
  {
    "altermo/iedit.nvim",
    -- https://github.com/altermo/iedit.nvim
    -- Edit one occurrence of text and simultaneously have other selected
    -- occurrences edited in the same way.
    keys = {
      {
        "<leader>r",
        mode = { "n", "x", "o" },
        function()
          require("iedit").select()
        end,
        desc = "Start iedit",
      },
    },
  },
}
