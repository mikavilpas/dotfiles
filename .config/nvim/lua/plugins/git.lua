---@module "lazy"
---@type LazySpec
return {
  {
    -- Search your git history by commit message, content and author in Neovim
    -- https://github.com/aaronhallaert/advanced-git-search.nvim
    "aaronhallaert/advanced-git-search.nvim",
    keys = {
      {
        "<leader><right>",
        mode = { "n", "v" },
        "<cmd>AdvancedGitSearch<cr>",
        { silent = true, desc = "AdvancedGitSearch" },
      },
    },
    cmd = { "AdvancedGitSearch" },
    config = function()
      -- optional: setup telescope before loading the extension
      require("telescope").setup({
        -- move this to the place where you call the telescope setup function
        extensions = {
          advanced_git_search = {
            -- See Config
          },
        },
      })

      require("telescope").load_extension("advanced_git_search")
    end,
    dependencies = {

      "nvim-telescope/telescope.nvim",
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
      {
        "<leader>gl",
        function()
          local current_file = vim.fn.expand("%")
          require("tsugit").toggle_for_file(current_file, {}, { "--screen-mode", "normal" })
        end,
        { silent = true, desc = "lazygit current_file" },
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
}
