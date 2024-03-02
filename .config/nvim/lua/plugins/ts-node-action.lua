---@type LazySpec
return {
  {
    -- https://github.com/ckolkey/ts-node-action
    -- Neovim Plugin for running functions on nodes.
    "ckolkey/ts-node-action",
    event = "BufRead",
    dependencies = { "nvim-treesitter" },
    opts = {},
    keys = {
      {
        "<leader><enter>",
        function()
          require("ts-node-action").node_action()
        end,
      },
    },
  },
  {
    -- https://github.com/Wansmer/treesj
    -- Neovim plugin for splitting/joining blocks of code

    "Wansmer/treesj",
    event = "BufRead",
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
    cmd = {
      "TSJToggle",
      "TSJSplit",
      "TSJJoin",
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
