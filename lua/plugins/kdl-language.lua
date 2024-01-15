return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "kdl",
      })
    end,
  },

  {
    "nvim-ts-context-commentstring",
    opts = {},
    config = {
      kdl = "// %s",
    },
  },
}
