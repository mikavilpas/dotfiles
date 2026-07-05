---@module "lazy"
---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  opts = {
    ---@type table<string, vim.lsp.Config>
    servers = {
      jsonls = {
        settings = {
          json = {
            -- use oxfmt or prettier for formatting, never jsonls
            format = { enable = false },
          },
        },
      },
    },
  },
}
