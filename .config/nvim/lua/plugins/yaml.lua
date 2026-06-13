---@module "lazy"
---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  opts = {
    ---@type table<string, vim.lsp.Config>
    servers = {
      -- yaml-language-server is installed with mise (npm:yaml-language-server),
      -- so don't let mason install a second copy.
      -- https://www.lazyvim.org/plugins/lsp#nvim-lspconfig
      yamlls = { mason = false },
    },
  },
}
