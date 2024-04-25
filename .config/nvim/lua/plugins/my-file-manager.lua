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
      "<up>",
      function()
        require("yazi").yazi()
      end,
      { desc = "Open the file manager" },
    },
  },
  ---@type YaziConfig
  opts = {
    open_for_directories = true,
    enable_mouse_support = true,
  },
}
