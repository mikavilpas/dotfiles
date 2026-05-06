---@module "lazy"
---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      taplo = { enabled = false },
      tombi = { mason = false },
    },
  },
}
