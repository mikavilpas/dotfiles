---@type LazySpec
return {
  -- https://www.lazyvim.org/extras/util/project
  "ahmedkhalf/project.nvim",
  opts = {
    -- seems to add projects to list automatically when I open files. Cool.
    manual_mode = false,
  },
  event = "VeryLazy",
  config = function(_, opts)
    require("project_nvim").setup(opts)
    require("lazyvim.util").on_load("telescope.nvim", function()
      require("telescope").load_extension("projects")
    end)
  end,
  keys = {
    { "<leader>fp", "<Cmd>Telescope projects<CR>", desc = "Projects" },
  },
}
