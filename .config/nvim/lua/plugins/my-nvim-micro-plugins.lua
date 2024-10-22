---@module "lazy"
---@type LazySpec
return {
  "mikavilpas/my-nvim-micro-plugins.nvim",
  -- dir = "~/git/my-nvim-micro-plugins.nvim/",
  keys = {
    {
      "<c-w><c-r>",
      mode = { "n" },
      function()
        require("my-nvim-micro-plugins.rotate").rotate_window()
      end,
    },
  },
}
