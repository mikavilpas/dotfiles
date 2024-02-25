---@type LazySpec
return {
  "DreamMaoMao/yazi.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
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
