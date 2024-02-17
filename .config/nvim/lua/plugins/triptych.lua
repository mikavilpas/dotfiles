-- Directory browser plugin for Neovim, inspired by Ranger
-- https://github.com/simonmclean/triptych.nvim
--
---@type LazySpec
return {
  "simonmclean/triptych.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "nvim-tree/nvim-web-devicons", -- optional
  },
}
