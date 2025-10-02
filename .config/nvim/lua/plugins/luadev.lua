---@module "lazy"
---@type LazySpec
return {
  { "LuaCATS/luassert", name = "luassert-types", lazy = true },
  { "LuaCATS/busted", name = "busted-types", lazy = true },
  { "Bilal2453/luvit-meta", name = "luvit-types", lazy = true },
  { "DrKJeff16/wezterm-types", name = "wezterm-types", lazy = true },
  {
    "folke/lazydev.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.library, {
        { path = "luassert-types/library", words = { "assert" } },
        { path = "luvit-types/library", words = { "vim%.uv" } },
        { path = "busted-types/library", words = { "describe" } },
        { path = "wezterm-types", mods = { "wezterm" } },
        { path = vim.env.VIMRUNTIME, words = { "vim" } },
      })
    end,
  },
}
