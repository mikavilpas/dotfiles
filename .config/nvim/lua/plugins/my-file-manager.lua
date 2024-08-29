---@module "yazi"

---@type LazySpec
return {
  {
    "mikavilpas/yazi.nvim",
    -- dir = "~/git/yazi.nvim/",
    event = "VeryLazy",
    keys = {
      { "<up>", "<cmd>Yazi<cr>", desc = "Open yazi" },
      { "<s-up>", "<cmd>Yazi cwd<cr>", desc = "Open yazi in cwd" },
      { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Open yazi with the last hovered file" },
    },
    ---@type YaziConfig
    opts = {
      use_ya_for_events_reading = true,
      use_yazi_client_id_flag = true,
      open_multiple_tabs = true,
      open_for_directories = true,
      -- log_level = vim.log.levels.DEBUG,
      integrations = {
        grep_in_directory = function(directory)
          require("my-nvim-micro-plugins.main").my_live_grep({ cwd = directory })
        end,
      },
    },
  },
  {
    name = "easyjump.yazi",
    url = "https://gitee.com/DreamMaoMao/easyjump.yazi.git",
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
    "yazi-rs/flavors",
    name = "yazi-flavor-catppuccin-macchiato",
    lazy = true,
    build = function(spec)
      require("yazi.plugin").build_flavor(spec, {
        sub_dir = "catppuccin-macchiato.yazi",
      })
    end,
  },
  {
    "ndtoan96/ouch.yazi",
    lazy = true,
    build = function(plugin)
      require("yazi.plugin").build_plugin(plugin)
    end,
  },
  {
    -- Simple lualine-like status line for yazi.
    -- https://github.com/llanosrocas/yaziline.yazi
    "llanosrocas/yaziline.yazi",
    lazy = true,
    build = function(plugin)
      require("yazi.plugin").build_plugin(plugin)
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = true,
    opts = {
      filesystem = {
        hijack_netrw_behavior = "disabled",
      },
    },
  },
}
