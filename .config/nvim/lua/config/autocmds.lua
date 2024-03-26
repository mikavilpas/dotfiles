-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- if the git COMMIT_EDITMSG file is closed, automatically display lazygit
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    local file = vim.fn.expand("<afile>")
    if file:match("COMMIT_EDITMSG") then
      _G.openLazyGit()
    end
  end,
})
