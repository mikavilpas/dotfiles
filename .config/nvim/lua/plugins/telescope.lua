---@type LazySpec
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",

      -- https://github.com/debugloop/telescope-undo.nvim
      --
      -- Usage:
      -- <leader>sc (search commands), then Telescope undo
      "debugloop/telescope-undo.nvim",

      {
        -- https://github.com/smartpde/telescope-recent-files
        -- Telescope extension for Neovim to pick a recent file
        "smartpde/telescope-recent-files",
        keys = {
          {
            "<leader>fr",
            mode = { "n", "v" },
            function()
              local telescope = require("telescope")
              telescope.load_extension("recent_files")
              telescope.extensions.recent_files.pick({
                only_cwd = true,
              })
            end,
            desc = "search recent_files (cwd)",
          },
        },
      },

      -- native telescope bindings to zf for sorting results.
      -- In short, zf is a filepath fuzzy finder. It is designed for better
      -- matching on filepaths than fzf or fzy. Matches on filenames are
      -- prioritized, and the strict path matching feature helps narrow down
      -- directory trees with precision. See the zf repo for full details.
      -- https://github.com/natecraddock/telescope-zf-native.nvim
      "natecraddock/telescope-zf-native.nvim",
    },
    keys = {
      { "<leader><leader>", false },
      {
        "<down>",
        mode = { "n", "v" },
        require("my-telescope-searches").my_find_file_in_project,
        { desc = "Find files (including in git submodules)" },
      },
      {
        "<leader>/",
        mode = { "n", "v" },
        function()
          require("my-telescope-searches").my_live_grep()
        end,
        desc = "search project 🤞🏻",
      },
      {
        "<leader>fR",
        mode = { "n", "v" },
        function()
          require("telescope").extensions.recent_files.pick({
            only_cwd = false,
          })
        end,
        desc = "search recent_files (global)",
      },
    },

    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        path_display = {
          filename_first = {
            reverse_directories = false,
          },
        },

        mappings = {
          n = {
            ["<C-y>"] = require("my-telescope-searches").my_copy_relative_path,
          },
          i = {
            ["<C-y>"] = require("my-telescope-searches").my_copy_relative_path,
          },
        },
      },

      extensions = {
        undo = {
          side_by_side = true,
          layout_strategy = "vertical",
          layout_config = {
            preview_height = 0.8,
          },

          mappings = {
            n = {
              ["<cr>"] = function(bufnr)
                return require("telescope-undo.actions").restore(bufnr)
              end,
            },
            i = {
              ["<cr>"] = function(bufnr)
                return require("telescope-undo.actions").restore(bufnr)
              end,
            },
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
      telescope.load_extension("undo")
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
}
