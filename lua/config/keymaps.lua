-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

local Util = require("lazyvim.util")

vim.keymap.set("n", "gs", function()
  vim.cmd("update")
end, { noremap = true, silent = true })

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "Disable New Line Comment",
})

-- open lazygit history for the current file
vim.keymap.set("n", "<leader>gl", function()
  local path = vim.api.nvim_buf_get_name(0)
  Util.terminal({ "lazygit", "--filter", path }, { cwd = Util.root(), esc_esc = false, ctrl_hjkl = false })
end, { desc = "Lazygit (root dir)" })

-- disable esc j and esc k moving lines accidentally
-- https://github.com/LazyVim/LazyVim/discussions/658
vim.keymap.set("n", "<A-k>", "<esc>k", { desc = "Move up" })
vim.keymap.set("n", "<A-j>", "<esc>j", { desc = "Move down" })
vim.keymap.set("i", "<A-k>", "<esc>gk", { desc = "Move up" })
vim.keymap.set("i", "<A-j>", "<esc>gj", { desc = "Move down" })
vim.keymap.set("v", "<A-k>", "<esc>gk", { desc = "Move up" })
vim.keymap.set("v", "<A-j>", "<esc>gj", { desc = "Move down" })

-- move to previous and next changes in the current file
vim.api.nvim_set_keymap("n", "-", "g;", { noremap = true })
vim.api.nvim_set_keymap("n", "+", "g,", { noremap = true })

--
-- search for the current visual mode selection
-- https://github.com/nvim-telescope/telescope.nvim/issues/2497#issuecomment-1676551193
local function get_visual()
  vim.cmd('noautocmd normal! "vy"')
  local text = vim.fn.getreg("v")
  vim.fn.setreg("v", {})

  text = string.gsub(text or "", "\n", "")
  if #text > 0 then
    return text
  else
    return ""
  end
end

vim.keymap.set("v", "<leader>/", function()
  local selection = get_visual()

  require("telescope.builtin").live_grep({
    default_text = selection,
    only_sort_text = true,
    additional_args = function()
      return { "--pcre2" }
    end,
  })
end, { noremap = true, desc = "Grep visual selection" })
