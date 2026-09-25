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
        before_init = function(params, config)
          -- https://github.com/actions/languageservices/tree/main/languageserver#in-neovim
          if vim.fn.executable("gh") ~= 1 then
            return
          end
          local token = vim.system({ "gh", "auth", "token" }):wait()
          if token.code ~= 0 then
            return
          end
          local host = vim.env.GH_HOST
          local options = {
            sessionToken = vim.trim(token.stdout),
            gitHubApiUrl = host and ("https://api." .. host) or nil,
          }

          -- With a token, `./` and `$/` references resolve only inside a
          -- repository listed here, matched by its workspaceUri.
          local git_root = config.root_dir and vim.fs.root(config.root_dir, ".git")
          if git_root then
            local repo = vim
              .system(
                { "gh", "api", "repos/{owner}/{repo}", "--jq", "[.id, .owner.login, .name, .owner.type] | @tsv" },
                { cwd = git_root }
              )
              :wait()
            local id, owner, name, owner_type = repo.stdout:match("^(%d+)\t(%S+)\t(%S+)\t(%S+)")
            if repo.code == 0 and id then
              options.repos = {
                {
                  id = tonumber(id),
                  owner = owner,
                  name = name,
                  organizationOwned = owner_type == "Organization",
                  workspaceUri = vim.uri_from_fname(git_root),
                },
              }
            end
          end

          params.initializationOptions = vim.tbl_extend("force", params.initializationOptions or {}, options)
        end,
        handlers = {
          -- The server looks up every action on the one API host it is given,
          -- so with a GitHub Enterprise host each public github.com action is
          -- reported as unresolvable.
          ["textDocument/publishDiagnostics"] = function(err, result, ctx)
            if vim.env.GH_HOST and result then
              result.diagnostics = vim.tbl_filter(function(diagnostic)
                return not diagnostic.message:match("^Unable to resolve action")
              end, result.diagnostics)
            end
            vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
          end,
        },
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
