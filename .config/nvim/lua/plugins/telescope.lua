---@module "lazy"
---@type LazySpec
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
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
    dependencies = { "kkharji/sqlite.lua" },
    event = "BufReadPost",
    keys = {
      {
        -- mnemonic: "paste"
        "<leader>p",
        function()
          --
          require("telescope").extensions.neoclip.default({})
        end,
        { desc = "Paste with telescope (neoclip)" },
      },
    },
    opts = {
      default_register = { "+" },
      enable_persistent_history = true,
    },
    config = function(_, opts)
      require("neoclip").setup(opts)
      require("telescope").load_extension("neoclip")
    end,
  },

  {
    "prochri/telescope-all-recent.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "kkharji/sqlite.lua",
      -- optional, if using telescope for vim.ui.select
      -- "stevearc/dressing.nvim"
    },
    opts = {
      -- your config goes here
    },
  },

  {
    -- FZF sorter for telescope written in c
    -- this gets enabled by LazyVim's telescope extra
    -- https://github.com/nvim-telescope/telescope-fzf-native.nvim
    "nvim-telescope/telescope-fzf-native.nvim",
    enabled = false,
  },

  {
    -- native telescope bindings to zf for sorting results
    "natecraddock/telescope-zf-native.nvim",
    config = function()
      require("telescope").load_extension("zf-native")
    end,
  },

  {
    "mikavilpas/nucleo.nvim",
    -- for now I like using telescope-zf-native. My telescope shows the
    -- filename_first and the path last, which is not well supported in the
    -- nucleo algorithm. It's more intuitive to use the zf algorithm because it
    -- prioritizes file names.
    enabled = false,
    -- https://github.com/mikavilpas/nucleo.nvim
    build = "cargo build --release",
    config = true,
    -- it sets itself as the default sorter for telescope's find_files (file
    -- picker)
  },
}
