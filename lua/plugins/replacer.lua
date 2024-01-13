return {
  "gabrielpoca/replacer.nvim",

  -- usage:
  -- - run telescope to search for a string somehow
  -- - <c-q> to save the results to a quickfix list
  -- - <leader>h to run replacer.nvim
  -- - <c-s> to save the changes
  opts = { rename_files = false },
  keys = {
    {
      "<leader>h",
      function()
        require("replacer").run()
      end,
      desc = "run replacer.nvim",
    },
  },
}
