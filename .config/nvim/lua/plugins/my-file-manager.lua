---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  -- dir = "~/git/yazi.nvim/",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = { "Yazi" },
  keys = {
    {
      "<leader>-",
      function()
        require("yazi").yazi()
      end,
      { desc = "Open the file manager" },
    },
  },
}
