return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "Marskey/telescope-sg" },
  keys = {
    -- disable the keymap to search files
    { "<leader><leader>", false },
  },

  opts = {
    defaults = {
      layout_strategy = "horizontal",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,
    },
  },
}
