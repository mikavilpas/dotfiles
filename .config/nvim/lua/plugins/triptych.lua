-- Directory browser plugin for Neovim, inspired by Ranger
-- https://github.com/simonmclean/triptych.nvim
--
---@type LazySpec
return {
  "simonmclean/triptych.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "nvim-tree/nvim-web-devicons", -- optional
  },

  config = function(_, opts)
    require("triptych").setup(opts)
  end,

  keys = {
    {
      "<leader>-",
      function()
        require("triptych.init").toggle_triptych()
      end,
    },
  },
}
