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
        before_init = function(params, _)
          -- https://github.com/actions/languageservices/tree/main/languageserver#in-neovim
          local token = vim.system({ "gh", "auth", "token" }):wait()
          if token.code ~= 0 then
            return
          end
          local host = vim.env.GH_HOST
          params.initializationOptions = vim.tbl_extend("force", params.initializationOptions or {}, {
            sessionToken = vim.trim(token.stdout),
            gitHubApiUrl = host and ("https://api." .. host) or nil,
          })
        end,
      })
      vim.lsp.enable("gh_actions_ls")

      vim.lsp.config("zizmor", {
        filetypes = { "yaml", "yaml.ghaction" },
        root_dir = function(bufnr, on_dir)
          on_dir(vim.fs.root(bufnr, ".git"))
        end,
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
