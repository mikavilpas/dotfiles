---@return LazySpec
return {
  {
    "bloznelis/before.nvim",
    keys = {
      {
        "ö",
        mode = { "n" },
        function()
          require("before").jump_to_last_edit()
        end,
        desc = "Jump to last edit",
      },
      {
        "ä",
        mode = { "n" },
        function()
          require("before").jump_to_next_edit()
        end,
        desc = "Jump to next edit",
      },
    },
  },
}
