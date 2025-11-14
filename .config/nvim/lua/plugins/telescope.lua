---@module "lazy"
---@type LazySpec
return {
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },
  {
    "nvim-telescope/telescope.nvim",
    -- right now, only use this to support plugins that depend on telescope
    lazy = true,
    dependencies = {},
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            width = 0.9,
            preview_width = 0.5,
          },
          prompt_position = "top",
        },
        sorting_strategy = "ascending",
        winblend = 0,
        path_display = {
          filename_first = {
            reverse_directories = false,
          },
        },
      },
    },

    config = function(_, opts)
      -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
      -- configs for us. We won't use data, as everything is in it's own namespace (telescope
      -- defaults, as well as each extension).
      local telescope = require("telescope")
      telescope.setup(opts)
    end,
  },

  {
    -- https://github.com/AckslD/nvim-neoclip.lua
    "AckslD/nvim-neoclip.lua",
    lazy = true,
    dependencies = { "kkharji/sqlite.lua" },
    event = "BufReadPost",
    keys = {
      {
        -- mnemonic: "paste"
        "<leader>p",
        function()
          --
          require("telescope").load_extension("neoclip")
          require("telescope").extensions.neoclip.default({})
        end,
        { desc = "Paste with telescope (neoclip)" },
      },
    },
    opts = {
      default_register = { "+" },
      enable_persistent_history = true,
    },
  },
}
