---@type LazySpec
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      -- https://github.com/zbirenbaum/copilot.lua?tab=readme-ov-file#setup-and-configuration
      suggestion = { enabled = true, auto_trigger = true },
      debounce = 300, --ms
      -- keys:
      -- accept the suggestion with <M-l> in insert mode

      filetypes = {
        markdown = true,
        help = true,
      },
    },

    config = function(_, opts)
      require("copilot").setup(opts)
    end,
  },
}
