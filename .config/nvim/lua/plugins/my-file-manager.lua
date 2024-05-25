---@type LazySpec
return {
  {
    "mikavilpas/yazi.nvim",
    -- dir = "~/git/yazi.nvim/",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    keys = {
      {
        "<up>",
        function()
          require("yazi").yazi()
        end,
        desc = "Open the file manager",
      },
      {
        "<s-up>",
        function()
          require("yazi").yazi(nil, vim.fn.getcwd())
        end,
        desc = "Open the file manager in the cwd",
      },
    },
    ---@type YaziConfig
    opts = {
      open_for_directories = true,
      enable_mouse_support = true,
      -- log_level = vim.log.levels.DEBUG,
      integrations = {
        grep_in_directory = function(directory)
          require("my-telescope-searches").my_live_grep({ cwd = directory })
        end,
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        hijack_netrw_behavior = "disabled",
      },
    },
  },

  -- HACK: Manage yazi plugins using lazy.nvim.
  -- https://github.com/folke/lazy.nvim
  --
  -- Benefits of this approach:
  -- - easily keep your yazi plugins up to date along with your neovim plugins.
  -- - use lazy.nvim's excellent ui to inspect the changes in the plugins.
  -- - use lazy-lock.json to lock the versions of these plugins in your dotfiles.
  -- - load plugins from all the locations lazy.nvim supports.
  -- - commit the symbolic links to your dotfiles git repository. They should work on all platforms.
  --
  -- NOTE: you must set `lazy = true` to make neovim not load them. They are only for yazi.
  {
    "DreamMaoMao/keyjump.yazi",
    lazy = true,
    build = function(plugin)
      require("yazi.plugin").build_plugin(plugin)
    end,
  },
  {
    "Rolv-Apneseth/starship.yazi",
    lazy = true,
    build = function(plugin)
      require("yazi.plugin").build_plugin(plugin)
    end,
  },
  {
    "ndtoan96/ouch.yazi",
    lazy = true,
    build = function(plugin)
      require("yazi.plugin").build_plugin(plugin)
    end,
  },
}
