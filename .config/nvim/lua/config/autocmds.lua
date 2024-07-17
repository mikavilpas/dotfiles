-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- if the git COMMIT_EDITMSG file is closed, automatically display lazygit
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    local file_name = vim.fn.expand("<afile>")
    if file_name:match("COMMIT_EDITMSG") then
      -- write to a backup file because sometimes lazygit fails to create a new
      -- commit, and the message can be lost
      local file = io.open(file_name, "r")
      if file == nil then
        vim.notify("Unable to open file: " .. file_name, vim.log.levels.ERROR)
        return
      end

      local contents = file:read("*all")
      local backup_file = io.open("COMMIT_EDITMSG.backup", "w+")
      if backup_file == nil then
        print("Could not open file for writing")
        return
      end
      local _, err = backup_file:write(contents)
      if err then
        vim.notify(string.format("Error writing to backup file: %s", err), vim.log.levels.ERROR)
      end
      file:close()

      require("lazygit").LazyGit_G.openLazyGit()

      _G.openLazyGit()
    end
  end,
})
