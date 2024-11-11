---@module "plenary.path"

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- if the git COMMIT_EDITMSG file is closed, automatically display lazygit
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    local file_name = vim.fn.expand("<afile>")

    if not file_name:match("COMMIT_EDITMSG") then
      return
    end

    -- write to a backup file because sometimes lazygit fails to create a new
    -- commit, and the message can be lost
    local plenary_path = require("plenary.path")
    ---@type Path
    local file = plenary_path:new(file_name)

    if not file:exists() then
      -- should not happen
      vim.notify(string.format("File does not exist: %s", file_name), vim.log.levels.ERROR)
      return
    end

    local contents = file:readlines()
    file:close()

    local backup_file_path = vim.fs.joinpath(vim.fs.dirname(file_name), "COMMIT_EDITMSG.backup")
    local backup_file = io.open(backup_file_path, "w+")
    if not backup_file then
      vim.notify(string.format("Failed to open file: %s", backup_file_path), vim.log.levels.ERROR)
      return
    end
    backup_file:write(table.concat(contents, "\n"))
    backup_file:close()

    local lastLazyGit = _G.lastLazyGit
    assert(lastLazyGit, "lastLazyGit is not set, so cannot reopen it. This is a bug 🐛.")

    vim.schedule(function()
      lastLazyGit:show()
    end)
  end,
})
