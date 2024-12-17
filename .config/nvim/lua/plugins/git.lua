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
        "<cmd>AdvancedGitSearch<cr>",
        { silent = true, desc = "AdvancedGitSearch" },
      },
    },
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
      },
      -- to open commits in browser with fugitive
      "tpope/vim-rhubarb",
      -- optional: to replace the diff from fugitive with diffview.nvim
      -- (fugitive is still needed to open in browser)
      -- "sindrets/diffview.nvim",
    },
  },

  {
    "fredeeb/tardis.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "Tardis" },
    config = true,
  },
  {
    "mikavilpas/tsugit.nvim",
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
    opts = {},
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
        ":DiffviewFileHistory %<cr>",
        { silent = true, desc = "Diffview file history" },
      },
    },
  },
}
