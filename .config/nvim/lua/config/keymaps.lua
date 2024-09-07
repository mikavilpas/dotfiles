-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

vim.keymap.set({ "t" }, "<esc><esc>", "<Nop>")
vim.keymap.set({ "n" }, "<leader>w", "<Nop>")

vim.keymap.set({ "n" }, "<leader>br", function()
  -- Reopen the current buffer/file to fix LSP warnings being out of sync. For
  -- some reason this seems to fix it.
  local state = {
    file = vim.fn.expand("%"),
    buffer = vim.api.nvim_get_current_buf(),
    scroll = vim.fn.winsaveview(),
  }
  -- save changes and reopen the file
  require("lazyvim.util.ui").bufremove(state.buffer)

  vim.cmd("edit " .. state.file)
  vim.fn.winrestview(state.scroll)
end, { desc = "Reopen buffer" })

vim.keymap.set({ "v" }, "s", "<Plug>(nvim-surround-visual)")

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "Disable New Line Comment",
})

vim.keymap.set("n", "<leader>gd", function()
  require("telescope.builtin").lsp_definitions({ jump_type = "vsplit" })
end, { desc = "Goto definition in vsplit" })

vim.keymap.set("n", "<leader>xl", function()
  vim.cmd("luafile %")
  vim.notify("Reloaded lua file", vim.log.levels.INFO)
end, { desc = "Reload file" })

vim.keymap.set("n", "<left>", function()
  local windows = vim.api.nvim_tabpage_list_wins(0)
  local win = windows[1]
  vim.api.nvim_win_close(win, true)
end, { desc = "Close leftmost window" })

local Terminal = require("toggleterm.terminal").Terminal

-- open lazygit history for the current file
vim.keymap.set("n", "<leader>gl", function()
  local absolutePath = vim.api.nvim_buf_get_name(0)
  openLazyGit("lazygit --filter " .. absolutePath)
end, { desc = "lazygit file commits" })

-- open lazygit in the current git directory
---@param cmd? string
local function openLazyGit(cmd)
  local lazygit = Terminal:new({
    cmd = cmd or "lazygit",
    dir = "git_dir",
    direction = "float",
    close_on_exit = true,
    float_opts = {
      -- lazygit itself already has a border
      border = "none",
    },
    on_open = function(term)
      -- these are added by LazyVim and they prevent moving commits up and down in lazygit
      -- https://github.com/LazyVim/LazyVim/blob/91126b9896bebcea9a21bce43be4e613e7607164/lua/lazyvim/config/keymaps.lua#L150
      vim.keymap.set({ "t" }, "<C-k>", function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-k>", true, false, true), "n", true)
      end, { buffer = term.bufnr })

      -- which-key v3 pops up when I press esc by default, causing esc to not work. Work around it.
      vim.keymap.set({ "t" }, "<esc>", function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)
      end, { buffer = term.bufnr })

      vim.keymap.set({ "t" }, "<C-j>", function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-j>", true, false, true), "n", true)
      end, { buffer = term.bufnr })
      vim.cmd("startinsert")
    end,
    on_close = function()
      vim.cmd("checktime")
    end,
  })

  lazygit:open()
end
-- vim.keymap.set("n", "<leader>gg", openLazyGit, { desc = "lazygit" })
vim.keymap.set("n", "<right>", openLazyGit, { desc = "lazygit" })

-- expose the openLazyGit function so it can be used in other files
_G.openLazyGit = openLazyGit

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

-- based mapping section from ThePrimeagen

-- joins lines without moving the cursor
vim.keymap.set("n", "J", "m9J`9", { desc = "Join line" })

-- move screen up and down but keep the cursor in place (less disorienting)
vim.keymap.set("n", "<C-u>", function()
  local screen_height = vim.api.nvim_win_get_height(0)

  vim.cmd("normal! " .. math.floor(screen_height / 2) .. "k")
  vim.cmd("normal! zz")
end, { desc = "Move screen up" })
vim.keymap.set("n", "<C-d>", function()
  local screen_height = vim.api.nvim_win_get_height(0)
  vim.cmd("normal! " .. math.floor(screen_height / 2) .. "j")
  vim.cmd("normal! zz")
end, { desc = "Move screen down" })

-- when searching, move to the next match and center the screen
vim.keymap.set("n", "n", "nzzzv", { desc = "Move to next match" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Move to previous match" })

local function at_eol()
  local herecol = vim.fn.col(".")
  local endcol = vim.fn.col("$")

  return herecol == (endcol - 1)
end

-- replace whatever is visually selected with the next pasted text, without overwriting the clipboard
-- NOTE: prime uses "<leader>p" but I use that for something else
vim.keymap.set("x", "p", function()
  local current_column = vim.fn.col(".")
  vim.cmd('normal! "_d')
  if at_eol() then
    vim.cmd("normal! p")
  else
    vim.cmd("normal! P")
  end

  vim.cmd("normal! " .. current_column .. "|")
end)

-- paste and stay in the same column
vim.keymap.set("n", "p", function()
  local current_column = vim.fn.virtcol(".")
  vim.cmd("normal! p")
  vim.cmd("normal! " .. current_column .. "|")
end)

-- easy navigation between diagnostic items such as errors
vim.keymap.set("n", "<leader>j", function()
  vim.cmd("normal ]d")
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>k", function()
  vim.cmd("normal [d")
end, { desc = "Previous diagnostic" })

-- the same thing for quickfix lists
vim.keymap.set("n", "<leader><down>", function()
  vim.cmd("silent! cnext")
end, { desc = "Next quickfix item" })
vim.keymap.set("n", "<leader><up>", function()
  vim.cmd("silent! cprev")
end, { desc = "Previous quickfix item" })

vim.keymap.set({ "n" }, "<leader>cy", function()
  require("my-nvim-micro-plugins.main").comment_line()
end, { desc = "Comment line", silent = true })

vim.keymap.set({ "v" }, "<leader>cy", function()
  local current_column = vim.fn.virtcol(".")
  -- yank the current selection and reactivate it in visual mode
  vim.cmd("normal ygv")

  -- comment the current selection and indent
  vim.cmd("normal gcgv=")

  -- jump to the end of the last visual selection and paste the yanked text
  vim.cmd("normal `>p")
  vim.cmd("normal " .. current_column .. "|")
end, { desc = "Comment line", silent = true })

-- Copy the current buffer path to the clipboard
-- https://stackoverflow.com/a/17096082/1336788
vim.keymap.set("n", "<leader>fyr", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
end, { desc = "Copy relative path to clipboard" })

-- full path
vim.keymap.set("n", "<leader>fyp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy full path to clipboard" })

-- just filename
vim.keymap.set("n", "<leader>fyf", function()
  vim.fn.setreg("+", vim.fn.expand("%:t"))
end, { desc = "Copy filename to clipboard" })

-- directory of the current file
vim.keymap.set("n", "<leader>fyd", function()
  vim.fn.setreg("+", vim.fn.expand("%:h"))
end, { desc = "Copy directory to clipboard" })

vim.keymap.set("v", "<leader>ä", function()
  local selection = require("my-nvim-micro-plugins.main").get_visual()
  vim.cmd("= " .. selection)
end, { desc = "Evaluate visual selection as lua" })

-- Remap y to ygv<esc> in visual mode so the cursor does not jump back to where
-- you started the selection.
-- https://www.reddit.com/r/neovim/comments/13y3thq/comment/jmm7tut/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
vim.keymap.set("v", "y", "ygv<esc>")

vim.keymap.set("n", "<backspace>", ":wa<cr>", { desc = "Save all files", silent = true })
