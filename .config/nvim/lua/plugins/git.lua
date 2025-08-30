---@module "lazy"
---@type LazySpec
return {
  {
    -- Search your git history by commit message, content and author in Neovim
    -- https://github.com/aaronhallaert/advanced-git-search.nvim
    "aaronhallaert/advanced-git-search.nvim",
    cmd = { "AdvancedGitSearch" },
    keys = {
      {
        "<leader><right>",
        mode = { "n", "v" },
        "<cmd>AdvancedGitSearch<cr>",
        { silent = true, desc = "AdvancedGitSearch" },
      },
    },
    config = function()
      require("advanced_git_search.snacks").setup({})
    end,
    dependencies = {
      "folke/snacks.nvim",

      -- to show diff splits and open commits in browser
      {
        "tpope/vim-fugitive",
        cmd = { "Git" },
        lazy = true,
        dependencies = {
          {
            "https://github.com/shumphrey/fugitive-gitlab.vim",
            ---@diagnostic disable-next-line: unused-local
            config = function(self, opts)
              vim.g.fugitive_gitlab_domains = {
                ["gitlab.com"] = "https://gitlab.com",
                ["gitlab.baronatechnologies.fi"] = "https://gitlab.baronatechnologies.fi",
              }
            end,
          },
        },
      },
      -- to open commits in browser with fugitive
      "tpope/vim-rhubarb",
      -- optional: to replace the diff from fugitive with diffview.nvim
      -- (fugitive is still needed to open in browser)
      -- "sindrets/diffview.nvim",
    },
  },

  {
    "mikavilpas/tsugit.nvim",
    version = "*",
    -- dir = "~/git/tsugit.nvim/",
    keys = {
      {
        "<right>",
        function()
          require("tsugit").toggle()
        end,
        { silent = true, desc = "toggle lazygit" },
      },
    },
    ---@type tsugit.UserConfig
    opts = {
      -- debug = true,
      integrations = {
        conform = {
          formatter = "prettierd",
        },
      },
    },
  },

  {
    -- Git integration for buffers
    -- https://github.com/lewis6991/gitsigns.nvim
    "lewis6991/gitsigns.nvim",
    keys = {
      {
        "<tab>",
        mode = { "n", "v" },
        function()
          require("gitsigns").nav_hunk("next", { target = "all", navigation_message = false })
        end,
        { silent = true, desc = "next hunk" },
      },
      {
        "<s-tab>",
        mode = { "n", "v" },
        function()
          require("gitsigns").nav_hunk("prev", { target = "all", navigation_message = false })
        end,
        { silent = true, desc = "prev hunk" },
      },
    },
  },

  {
    -- Single tabpage interface for easily cycling through diffs for all
    -- modified files for any git rev.
    -- https://github.com/sindrets/diffview.nvim
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
    },
    keys = {
      {
        "<leader>gl",
        mode = { "n" },
        "<cmd>DiffviewFileHistory %<cr>",
        { desc = "Diffview file history" },
      },
    },
  },
}
