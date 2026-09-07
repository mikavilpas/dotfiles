---@module "conform"

-- This is this file before it was reverted to using prettier instead of prettierd
-- https://github.com/LazyVim/LazyVim/blob/91126b9896bebcea9a21bce43be4e613e7607164/lua/lazyvim/plugins/extras/formatting/prettier.lua
-- https://github.com/LazyVim/LazyVim/commit/57b504b9e8ae95c294c17e97e7f017f6f802ebbc?diff=split&w=0
---@module "lazy"
---@type LazySpec
return {
  -- prettierd is installed and updated via mise, so it is not added to mason's
  -- ensure_installed. conform finds it on PATH.
  {
    "stevearc/conform.nvim",
    ---@type conform.setupOpts
    opts = {
      undojoin = true,
      formatters = {
        prettierd = {
          -- only run prettier in projects that use it
          require_cwd = true,

          cwd = function(_, ctx)
            local gitdir = vim.fs.root(ctx.dirname, { ".git" }) or "not-found"

            local configs = {
              -- https://github.com/stevearc/conform.nvim/blob/016802de402556da54c36bd7359b441266b01cdd/lua/conform/formatters/prettierd.lua?plain=1#L5-L25
              ".prettierrc",
              ".prettierrc.json",
              ".prettierrc.yml",
              ".prettierrc.yaml",
              ".prettierrc.json5",
              ".prettierrc.js",
              ".prettierrc.cjs",
              ".prettierrc.mjs",
              ".prettierrc.ts",
              ".prettierrc.cts",
              ".prettierrc.mts",
              ".prettierrc.toml",
              "prettier.config.js",
              "prettier.config.cjs",
              "prettier.config.mjs",
              "prettier.config.ts",
              "prettier.config.cts",
              "prettier.config.mts",
            }
            -- bound the search to the nearest git directory
            local prettier_config = vim.fs.root(ctx.dirname, function(name, path)
              if not vim.tbl_contains(configs, name) then
                return false
              end

              local in_git_dir = vim.startswith(path, gitdir)
              if not in_git_dir then
                return false
              end

              return true
            end)
            return prettier_config
          end,
        },
      },
      formatters_by_ft = {
        ["dockerfile"] = { "dockerfmt" },
        -- oxfmt is preferred if it's available - it's used through its lsp to
        -- avoid overhead and conflicts with versions
        ["javascript"] = { "prettierd" },
        ["javascriptreact"] = { "prettierd" },
        ["typescript"] = { "prettierd" },
        ["typescriptreact"] = { "prettierd" },
        ["vue"] = { "prettierd" },
        ["css"] = { "prettierd" },
        ["scss"] = { "prettierd" },
        ["less"] = { "prettierd" },
        ["html"] = { "prettierd" },
        ["json"] = { "prettierd" },
        ["jsonc"] = { "prettierd" },
        ["json5"] = { "prettierd" },
        ["yaml"] = { "prettierd" },
        ["markdown"] = { "prettierd" },
        ["markdown.mdx"] = { "prettierd" },
        ["graphql"] = { "prettierd" },
        ["handlebars"] = { "prettierd" },
        -- currently prettier-plugin-toml is not configurable, and I don't like
        -- the default formatting
        -- ["toml"] = { "prettier" },
      },
    },
  },
}
