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

-- bidirectional search
vim.keymap.set("n", "<leader><leader>", function()
  require("leap").leap({ target_windows = { vim.api.nvim_get_current_win() } })
end)
