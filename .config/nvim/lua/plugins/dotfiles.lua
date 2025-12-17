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

      local function link_theme(theme_name)
        symlink(
          vim.fs.normalize(vim.fs.joinpath(self.dir, "themes", theme_name .. ".tmTheme")),
          vim.fn.expand("~/dotfiles/.config/bat/themes/" .. theme_name .. ".tmTheme")
        )
      end
      link_theme("Catppuccin Frappe")
      link_theme("Catppuccin Latte")
      link_theme("Catppuccin Mocha")
      link_theme("Catppuccin Macchiato")

      vim.system({ "bat", "cache", "--build" }, { text = true })
    end,
  },

  {
    "catppuccin/glamour",
    name = "catppuccin-glamour",
    lazy = true,
    build = function(self)
      local target_dir = vim.fn.expand("~/dotfiles/.config/glow/themes")
      vim.fn.mkdir(target_dir, "p")

      -- themes/catppuccin-frappe.json
      -- themes/catppuccin-latte.json
      -- themes/catppuccin-macchiato.json
      -- themes/catppuccin-mocha.json
      local function link_theme(flavor)
        local filename = "catppuccin-" .. flavor .. ".json"
        symlink(vim.fs.normalize(vim.fs.joinpath(self.dir, "themes", filename)), vim.fs.joinpath(target_dir, filename))
      end
      link_theme("frappe")
      link_theme("latte")
      link_theme("mocha")
      link_theme("macchiato")
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
  {
    "https://github.com/catppuccin/fish",
    name = "catppuccin-fish",
    lazy = true,
    build = function(self)
      symlink(
        vim.fs.normalize(vim.fs.joinpath(self.dir, "themes", "Catppuccin Macchiato.theme")),
        vim.fn.expand("~/.config/fish/themes/Catppuccin Macchiato.theme")
      )
    end,
  },
  {
    "https://github.com/catppuccin/atuin",
    name = "catppuccin-atuin",
    lazy = true,
    build = function(self)
      local source_themes_path = vim.fs.joinpath(self.dir, "themes/macchiato")

      local target_themes_path = vim.fn.expand("~/dotfiles/.config/atuin/themes")
      local files = vim.fn.glob(source_themes_path .. "/*", true, true)
      for _, file in ipairs(files) do
        local filename = vim.fs.basename(file)
        local target = vim.fs.joinpath(target_themes_path, filename)
        symlink(file, target)
      end
    end,
  },
}
