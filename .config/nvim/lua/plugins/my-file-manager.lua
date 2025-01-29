---@module "lazy"
---@module "yazi"

---@type LazySpec
return {
  {
    "mikavilpas/yazi.nvim",
    -- dir = "~/git/yazi.nvim/",
    event = "UiEnter",
    keys = {
      { "<up>", "<cmd>Yazi<cr>", desc = "Open yazi" },
      { "<s-up>", "<cmd>Yazi cwd<cr>", desc = "Open yazi in cwd" },
      { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Open yazi with the last hovered file" },
    },
    ---@type YaziConfig
    opts = {
      open_multiple_tabs = true,
      open_for_directories = true,
      floating_window_scaling_factor = {
        width = 0.95,
        height = 0.95,
      },
      -- log_level = vim.log.levels.DEBUG,
      integrations = {
        grep_in_directory = function(directory)
          require("my-nvim-micro-plugins.main").my_live_grep({ cwd = directory })
        end,
      },
      future_features = {
        process_events_live = true,
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
    -- https://github.com/yazi-rs/plugins
    "yazi-rs/plugins",
    name = "yazi-rs-plugins",
    lazy = true,
    build = function(plugin)
      require("yazi.plugin").build_plugin(plugin, {
        sub_dir = "git.yazi",
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
    opts = {
      -- ../../../../../.local/share/nvim/lazy/neo-tree.nvim/lua/neo-tree/defaults.lua
      sources = {
        "filesystem",
      },
      mappings = {
        ["<cr>"] = { "open", config = { expand_nested_files = true } }, -- expand nested file takes precedence
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
        },
        hijack_netrw_behavior = "disabled",
      },
      follow_current_file = { enabled = true },
    },
  },
}
