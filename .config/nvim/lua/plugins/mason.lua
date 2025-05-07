---@module "lazy"
---@type LazySpec
-- add any tools you want to have installed below
return {
  { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
  {
    "mason-org/mason.nvim",
    version = "^1.0.0",
    opts = {
      ensure_installed = {
        -- lua
        "stylua",
        "selene",

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
