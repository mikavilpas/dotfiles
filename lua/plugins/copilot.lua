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
      filetypes = {
        markdown = true,
        help = true,
      },
    },

    config = function(_, opts)
      local copilot = require("copilot")
      copilot.setup(opts)

      vim.keymap.set("i", "<S-Enter>", function()
        require("copilot.suggestion").accept_line()
      end)
    end,
  },
}
