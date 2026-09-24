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
        on_attach = function(client)
          -- The `format.enable = false` setting above does NOT stop jsonls from
          -- advertising `documentFormattingProvider`, so `vim.lsp.buf.format`
          -- still invokes it. When conform has no formatter for the buffer (e.g.
          -- a JSON file in a project without prettier), LazyVim falls back to LSP
          -- formatting, which then runs BOTH jsonls and oxfmt -> double format +
          -- cursor jump. Drop the capability so only oxfmt formats.
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      },
    },
  },
}
