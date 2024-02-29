---@type LazySpec
return {
  {
    "ckolkey/ts-node-action",
    dependencies = { "nvim-treesitter" },
    opts = {},
  },
  {
    -- https://github.com/Wansmer/treesj
    -- Neovim plugin for splitting/joining blocks of code

    "Wansmer/treesj",
    keys = {
      {
        "<enter>",
        function()
          require("treesj").toggle()
        end,
      },
    },
    opts = {
      use_default_keymaps = false,
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
