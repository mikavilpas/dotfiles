---@type LazySpec
return {
  {
    -- Some Neovim plugins and features can make Neovim slow when editing big
    -- files and executing macros. Faster.nvim will selectively disable some
    -- features when big file is opened or macro is executed.
    -- https://github.com/pteroctopus/faster.nvim
    "pteroctopus/faster.nvim",
  },
}
