---@module "lazy"
---@type LazySpec
return {
  {
    "ohmyzsh/ohmyzsh",
    lazy = true,
    build = function(self)
      require("yazi.plugin").symlink(self, vim.fn.expand("~/.oh-my-zsh"))
    end,
  },

  {
    "catppuccin/bat",
    name = "catppuccin-bat",
    lazy = true,
    build = function(self)
      require("yazi.plugin").symlink(self, vim.fn.expand("~/dotfiles/.config/bat/themes/catppuccin-bat"))
      vim.system({ "bat", "cache", "--build" }, { text = true })
    end,
  },
}
