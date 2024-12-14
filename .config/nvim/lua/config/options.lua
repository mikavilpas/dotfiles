-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- hide all kinds of line numbers
vim.opt.relativenumber = false
vim.opt.number = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.scrolloff = 15 -- makes sure zt and zb have some context
vim.o.pumheight = 0 -- take as much space as needed
vim.o.timeoutlen = 100
vim.o.ttimeoutlen = 10

vim.g.snacks_animate = false
vim.g.snacks_scroll = false

-- disable pop up menu transparency
vim.opt.pumblend = 0

vim.g.maplocalleader = " "

-- **lazygit** now automatically uses the colors of your current colorscheme.
-- This is enabled by default. To disable, add the below to your `options.lua`:
-- https://github.com/LazyVim/LazyVim/commit/7d0dbc6dedc2d6cb4c3bc77fa296dc07ce5927c9
vim.g.lazygit_config = false
