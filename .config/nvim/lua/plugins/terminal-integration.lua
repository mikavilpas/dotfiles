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

    -- disable for headless and embedded neovim
    enabled = function()
      -- TODO disable this when debugging. Currently needs to be done manually
      -- for _, value in ipairs(vim.v.argv) do
      --   if value == "--headless" or value == "--embed" then
      --     return false
      --   end
      -- end

      return true
    end,

    opts = {
      window = {
        open = "alternate",
      },
    },
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    ---@type ToggleTermConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      float_opts = {
        border = "curved",
      },
    },
  },
}
