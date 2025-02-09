---@module "lazy"
---@module "snacks"
---@type LazySpec
return {
  {
    -- With the release of Neovim 0.6 we were given the start of extensible
    -- core UI hooks (vim.ui.select and vim.ui.input). They exist to allow
    -- plugin authors to override them with improvements upon the default
    -- behavior, so that's exactly what we're going to do.
    -- https://github.com/stevearc/dressing.nvim
    "stevearc/dressing.nvim",
    opts = { input = { insert_only = false } },
  },
  {
    -- 🍿 A collection of small QoL plugins for Neovim
    -- https://github.com/folke/snacks.nvim
    "folke/snacks.nvim",
    keys = {
      -- prevent conflicts with hop
      { "<leader><leader>", false },
      {
        "<down>",
        mode = { "n", "v" },
        function()
          require("my-nvim-micro-plugins.main").my_find_file_in_project()
        end,
        { desc = "Find files (including in git submodules)" },
      },
      {
        "<leader>/",
        mode = { "n", "v" },
        function()
          require("my-nvim-micro-plugins.main").my_live_grep({})
        end,
        desc = "search project 🤞🏻",
      },
    },

    ---@type snacks.Config
    opts = {
      scope = {
        edge = false,
      },
      notifier = {
        -- position notifications at the bottom, rather than at the top
        top_down = false,
      },

      picker = {
        layout = {
          -- this is based on the telescope preset, but modified
          -- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md#telescope
          layout = {
            box = "horizontal",
            backdrop = false,
            width = 0.90,
            height = 0.90,
            border = "none",
            {
              box = "vertical",
              { win = "input", height = 1, border = "rounded", title = "{title} {live} {flags}", title_pos = "center" },
              { win = "list", title = " Results ", title_pos = "center", border = "rounded" },
            },
            {
              win = "preview",
              title = "{preview:Preview}",
              width = 0.45,
              border = "rounded",
              title_pos = "center",
            },
          },
        },
        win = {
          input = {
            keys = {
              -- my-nvim-micro-plugins defines this
              ["<C-y>"] = { "my_copy_relative_path", mode = { "n", "i" } },
            },
          },
        },
      },
    },
  },
}
