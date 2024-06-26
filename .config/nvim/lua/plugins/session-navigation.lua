---@type LazySpec
return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    keys = {
      {
        "<leader>he",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Open harpoon window",
      },
      {
        "<leader>ha",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Harpoon add file",
      },
      {
        "ö",
        function()
          require("harpoon"):list():prev()
        end,
        desc = "Harpoon previous file",
      },
      {
        "ä",
        function()
          require("harpoon"):list():next()
        end,
        desc = "Harpoon next file",
      },
    },

    config = function()
      require("harpoon"):setup({
        settings = {
          get_root_dir = function()
            return require("my-telescope-searches").find_project_root()
          end,
        },
      })
    end,
  },
}
