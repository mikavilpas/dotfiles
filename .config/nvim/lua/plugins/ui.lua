--- @type snacks.picker.layout.Config
local my_layout = {
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
}

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

    ---@type snacks.Config | {}
    opts = {
      scope = {
        edge = false,
      },
      notifier = {
        -- position notifications at the bottom, rather than at the top
        top_down = false,
      },

      picker = {
        formatters = {
          file = {
            truncate = 100,
          },
        },
        sources = {
          autocmds = { layout = my_layout },
          buffers = { layout = my_layout },
          explorer = { layout = my_layout },
          cliphist = { layout = my_layout },
          colorschemes = { layout = my_layout },
          command_history = { layout = my_layout },
          commands = { layout = my_layout },
          diagnostics = { layout = my_layout },
          diagnostics_buffer = { layout = my_layout },
          files = { layout = my_layout },
          git_branches = { layout = my_layout },
          git_files = { layout = my_layout },
          git_grep = { layout = my_layout },
          git_log = { layout = my_layout },
          git_log_file = { layout = my_layout },
          git_log_line = { layout = my_layout },
          git_stash = { layout = my_layout },
          git_status = { layout = my_layout },
          git_diff = { layout = my_layout },
          grep = { layout = my_layout },
          grep_buffers = { layout = my_layout },
          grep_word = { layout = my_layout },
          help = { layout = my_layout },
          highlights = { layout = my_layout },
          icons = { layout = my_layout },
          jumps = { layout = my_layout },
          keymaps = { layout = my_layout },
          lazy = { layout = my_layout },
          -- lines = { layout = my_layout },
          loclist = { layout = my_layout },
          lsp_config = { layout = my_layout },
          lsp_declarations = { layout = my_layout },
          lsp_definitions = { layout = my_layout },
          lsp_implementations = { layout = my_layout },
          lsp_references = { layout = my_layout },
          lsp_symbols = { layout = my_layout },
          lsp_workspace_symbols = { layout = my_layout },
          lsp_type_definitions = { layout = my_layout },
          man = { layout = my_layout },
          marks = { layout = my_layout },
          notifications = { layout = my_layout },
          pickers = { layout = my_layout },
          picker_actions = { layout = my_layout },
          picker_format = { layout = my_layout },
          picker_layouts = { layout = my_layout },
          picker_preview = { layout = my_layout },
          projects = { layout = my_layout },
          qflist = { layout = my_layout },
          recent = { layout = my_layout },
          registers = { layout = my_layout },
          resume = { layout = my_layout },
          search_history = { layout = my_layout },
          select = { layout = my_layout },
          smart = { layout = my_layout },
          spelling = { layout = my_layout },
          treesitter = { layout = my_layout },
          undo = { layout = my_layout },
          zoxide = { layout = my_layout },
        },
        win = {
          input = {
            keys = {
              -- yazi.nvim defines this
              -- https://github.com/mikavilpas/yazi.nvim/blob/main/documentation/copy-relative-path-to-files.md
              ["<C-y>"] = { "yazi_copy_relative_path", mode = { "n", "i" } },
            },
          },
        },
      },
    },
  },

  {
    "smear-cursor.nvim",
    -- https://github.com/sphamba/smear-cursor.nvim
    opts = {
      smear_insert_mode = false,
      never_draw_over_target = true,
    },
  },
}
