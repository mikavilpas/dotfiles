---@module "lazy"
---@module "flatten"

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
    enabled = function()
      -- if the YAZI_ID environment variable is set, then we are in a yazi
      -- session. To avoid issues with bulk renaming, we disable flatten.nvim
      return vim.env.YAZI_ID == nil
    end,
    opts = {
      window = {
        open = "alternate",
      },
    },
  },
}
