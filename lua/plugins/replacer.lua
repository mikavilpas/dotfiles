---@type LazySpec
return {
  "gabrielpoca/replacer.nvim",

  -- usage:
  -- - run telescope to search for a string somehow
  -- - <c-q> to save the results to a quickfix list
  -- - run replacer.nvim with the keybinding below
  -- - <c-s> to save the changes
  opts = { rename_files = false },
  keys = {
    {
      "<leader>H",
      function()
        require("replacer").run()
      end,
      desc = "run replacer.nvim",
    },
  },
}
