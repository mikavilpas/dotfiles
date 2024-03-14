---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  -- dir = "~/git/yazi.nvim/",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = "VeryLazy",
  keys = {
    {
      "<leader>-",
      function()
        require("yazi").yazi()
      end,
      { desc = "Open the file manager" },
    },
  },
  ---@type YaziConfig
  opts = {
    open_for_directories = true,
  },
}
