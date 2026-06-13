---@module "lazy"
---@type LazySpec
-- add any tools you want to have installed below
return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    config = function(_, _)
      vim.lsp.config("gh_actions_ls", {
        filetypes = { "yaml", "yaml.ghaction" },
      })
      vim.lsp.enable("gh_actions_ls")

      vim.lsp.config("zizmor", {
        filetypes = { "yaml", "yaml.ghaction" },
      })
      vim.lsp.enable("zizmor")
    end,
  },
  {
    "mason-org/mason.nvim",
    -- opts = {
    --   ensure_installed = {
    --     -- lua
    --     "stylua",
    --     "selene",
    --
    --     -- shell
    --     "shellcheck",
    --     "shfmt",
    --
    --     -- markdown
    --     "marksman",
    --
    --     -- general / web development
    --     "prettier",
    --     -- "tailwindcss-language-server",
    --   },
    -- },
    opts = function(_, opts)
      -- remove tools from the ensure_installed list as I manage them with mise
      local mise_managed = { hadolint = true, shfmt = true, stylua = true }
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return not mise_managed[tool]
      end, opts.ensure_installed)

      return opts
    end,
  },
}
