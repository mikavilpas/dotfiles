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
      -- remove hadolint from the ensure_installed list. It gets added by
      -- LazyVim's docker extension but I manage it with mise
      for i, tool in ipairs(opts.ensure_installed) do
        if tool == "hadolint" then
          table.remove(opts.ensure_installed, i)
          break
        end
      end

      return opts
    end,
  },
}
