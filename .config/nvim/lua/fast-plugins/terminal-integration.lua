---@type LazySpec
return {
  {
    -- Open files and command output from wezterm, kitty, and neovim terminals in
    -- your current neovim instance
    -- https://github.com/willothy/flatten.nvim
    "willothy/flatten.nvim",

    -- Ensure that it runs first to minimize delay when opening file from terminal
    lazy = false,
    priority = 1001,
    enabled = true,
    opts = function()
      return {
        window = {
          open = "alternate",
        },
      }
    end,
  },
}
