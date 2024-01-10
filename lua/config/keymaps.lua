-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set("n", "gs", function()
  vim.cmd("update")
end, { noremap = true, silent = true })

-- Increment and decrement numbers
vim.keymap.set("n", "+", "<C-a>")
vim.keymap.set("n", "-", "<C-x>")

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "Disable New Line Comment",
})

local Util = require("lazyvim.util")

-- open lazygit history for the current file
vim.keymap.set("n", "<leader>gl", function()
  local path = vim.api.nvim_buf_get_name(0)
  Util.terminal({ "lazygit", "--filter", path }, { cwd = Util.root(), esc_esc = false, ctrl_hjkl = false })
end, { desc = "Lazygit (root dir)" })
