local function symlink(source, target)
  local existing_stat = vim.uv.fs_lstat(target)
  if existing_stat and existing_stat.type == "link" then
    -- try to remove the symlink as we will soon create a new one
    vim.uv.fs_unlink(target)
  end

  local success, error = vim.uv.fs_symlink(source, target)
  if not success then
    vim.notify("Failed to create symlink: " .. error, vim.log.levels.ERROR)
  end
end

---@module "lazy"
---@type LazySpec
return {
  {
    "catppuccin/bat",
    name = "catppuccin-bat",
    lazy = true,
    build = function(self)
      vim.fn.mkdir(vim.fn.expand("~/dotfiles/.config/bat/themes"), "p")

      -- themes/Catppuccin Frappe.tmTheme
      -- themes/Catppuccin Latte.tmTheme
      -- themes/Catppuccin Macchiato.tmTheme
      -- themes/Catppuccin Mocha.tmTheme

      symlink(
        vim.fs.normalize(vim.fs.joinpath(self.dir, "themes", "Catppuccin Macchiato.tmTheme")),
        vim.fn.expand("~/dotfiles/.config/bat/themes/Catppuccin Macchiato.tmTheme")
      )

      vim.system({ "bat", "cache", "--build" }, { text = true })
    end,
  },

  {
    "catppuccin/delta",
    name = "catppuccin-delta",
    lazy = true,
    build = function(self)
      require("yazi.plugin").symlink(self, vim.fn.expand("~/dotfiles/.config/delta/catppuccin-delta"))
    end,
  },
}
