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
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return tool ~= "hadolint" and tool ~= "shfmt"
      end, opts.ensure_installed)

      return opts
    end,
  },
}
