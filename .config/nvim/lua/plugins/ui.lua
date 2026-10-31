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
    "https://github.com/saghen/blink.indent",
    event = "VeryLazy",
    --- @module 'blink.indent'
    --- @type blink.indent.Config
    opts = {
      static = { enabled = false },
      scope = {
        indent_at_cursor = true,
        char = "▏",
        highlights = { "MyIndentScope" },
      },
      mappings = {
        object_scope = "",
        object_scope_with_border = "",
        goto_top = "",
        goto_bottom = "",
      },
    },
    keys = (function()
      -- Upstream's goto_top/goto_bottom always land on the border line (one
      -- line outside the scope) and have no option to change that. This is
      -- the previous behavior: land on the first/last line of the scope.
      ---@param side "top" | "bottom"
      local goto_scope_edge = function(side)
        return function()
          local parser = require("blink.indent.parser")
          local scope = parser.get_scope()
          if scope.indent_level == 0 then
            return
          end

          -- count1 is reset by the jumplist command
          local count = vim.v.count1
          if vim.fn.mode() == "n" then
            vim.cmd("normal! m`")
          end

          for _ = 1, count do
            local line = side == "top" and scope.start_line or scope.end_line
            vim.api.nvim_win_set_cursor(0, { line, 0 })
            vim.cmd("normal! ^")

            scope = parser.get_scope()
            if scope.indent_level == 0 then
              return
            end
          end
        end
      end

      return {
        { "ö", goto_scope_edge("top"), mode = { "n", "x", "o" }, desc = "Go to indent scope top" },
        { "ä", goto_scope_edge("bottom"), mode = { "n", "x", "o" }, desc = "Go to indent scope bottom" },
      }
    end)(),
  },

  {
    -- 🍿 A collection of small QoL plugins for Neovim
    -- https://github.com/folke/snacks.nvim
    "folke/snacks.nvim",
    init = function()
      -- open a vertical split next to the intro dashboard on startup
      vim.api.nvim_create_autocmd("User", {
        pattern = "SnacksDashboardOpened",
        once = true,
        callback = function()
          vim.cmd("vnew")
        end,
      })
    end,
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
        enabled = false,
        -- edge = false,
      },
      indent = {
        enabled = false,
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
