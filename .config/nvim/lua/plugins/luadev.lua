---@module "lazy"
---@type LazySpec
return {
  { "LuaCATS/luassert", name = "luassert-types", lazy = true },
  { "LuaCATS/busted", name = "busted-types", lazy = true },
  { "Bilal2453/luvit-meta", name = "luvit-types", lazy = true },
  {
    "https://github.com/FelipeLema/lazydev.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.library, {
        { path = "luassert-types/library", words = { "assert" } },
        { path = "luvit-types/library", words = { "vim%.uv" } },
        { path = "busted-types/library", words = { "describe" } },
        { path = vim.env.VIMRUNTIME, words = { "vim" } },
      })

      require("lazydev").setup()

      vim.lsp.config("emmylua_ls", {
        -- when developing the tool
        -- cmd = { "/Users/mikavilpas/git/emmylua-analyzer-rust/target/debug/emmylua_ls" },
      })
      vim.lsp.enable("emmylua_ls")
    end,
  },
}
