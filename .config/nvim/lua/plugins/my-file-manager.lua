---@type LazySpec
return {
  dir = "~/dotfiles/.config/nvim/lua/embedded-plugins/my-file-manager/",
  dependencies = {
    "LazyVim/LazyVim",
  },

  keys = {
    {
      "<leader>-",
      function()
        require("my-file-manager").open_lf()
      end,
      { desc = "Open the file manager" },
    },
  },
}
