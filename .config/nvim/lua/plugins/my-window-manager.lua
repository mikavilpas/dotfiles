---@type LazySpec
return {
  -- TODO not released yet
  -- "mikavilpas/shoji.nvim",
  dir = "~/git/shoji.nvim/",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = "VeryLazy",
  keys = {
    {
      "<left>",
      function()
        require("shoji").shoji()
      end,
    },
    {
      "<leader>w<right>",
      function()
        require("shoji").close_first_window()
      end,
      desc = "Close the first closeable window",
    },
  },
  ---@type ShojiConfig
  opts = {
    window_should_be_closed_function = function(window_info)
      return window_info.wind_config.width < 100
    end,
  },
}
