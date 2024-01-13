return {
  "ckolkey/ts-node-action",
  dependencies = { "nvim-treesitter" },
  opts = {},
  config = function()
    require("ts-node-action").setup()
  end,
}
