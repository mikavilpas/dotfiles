---@module "lazy"
---@type LazySpec
return {
  { "LuaCATS/luassert", name = "luassert-types", lazy = true },
  { "LuaCATS/busted", name = "busted-types", lazy = true },
  {
    "https://github.com/FelipeLema/lazydev.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.library, {
        { path = "luassert-types/library", words = { "assert" } },
        { path = "busted-types/library", words = { "describe" } },
        { path = vim.env.VIMRUNTIME, words = { "vim" } },
      })

      vim.lsp.enable("emmylua_ls")
    end,
  },
}
