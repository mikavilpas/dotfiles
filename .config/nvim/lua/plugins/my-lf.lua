---@type LazySpec
return {
  dir = "~/dotfiles/.config/nvim/lua/embedded-plugins/my-lf/",
  dependencies = {
    "LazyVim/LazyVim",
  },

  keys = {
    {
      "<leader>-",
      function()
        require("my-lf").open_lf()
      end,
      { desc = "Open lf" },
    },
  },
}
