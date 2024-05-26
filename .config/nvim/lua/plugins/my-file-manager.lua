---@type LazySpec
return {
  ---@type LazyPlugin
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
