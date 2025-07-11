---@module "lazy"
---@type LazySpec
-- add any tools you want to have installed below
return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      -- make sure mason-lspconfig does not automatically enable any LSP
      -- servers that might be installed on the system. We want to only use the
      -- LSP servers that are included in the test setup.
      automatic_enable = false,
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- lua
        "stylua",
        "selene",
        "emmylua_ls",

        -- shell
        "shellcheck",
        "shfmt",

        -- markdown
        "marksman",

        -- general / web development
        "prettier",
        -- "tailwindcss-language-server",
        "yaml-language-server",
      },
    },
  },
}
