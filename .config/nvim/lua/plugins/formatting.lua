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
    ---@type conform.FormatOpts
    opts = {
      undojoin = true,
      formatters = {
        prettierd = {
          -- only run prettier in projects that use it
          require_cwd = true,
        },
        oxfmt = {
          -- oxfmt is installed globally via mise, so conform would otherwise run
          -- it on every file everywhere - including projects that use prettier.
          -- Instead, defer to the oxfmt language server.
          --
          -- conform's own builtin `cwd` markers are not enough here: they count
          -- any vite.config.{ts,js} as an oxfmt project, which would hijack Vite
          -- repos that format with prettier.
          condition = function(_, ctx)
            if next(vim.lsp.get_clients({ bufnr = ctx.buf, name = "oxfmt" })) ~= nil then
              return true
            end
            -- The server attaches asynchronously, so a save very early in a
            -- buffer's life can race it. Ask its root_dir directly in that case,
            -- otherwise a parent directory's .prettierrc could win the race and
            -- reformat an oxfmt project with prettier.
            local config = vim.lsp.config.oxfmt
            if type(config) ~= "table" or type(config.root_dir) ~= "function" then
              return false
            end
            local root = nil
            config.root_dir(ctx.buf, function(dir)
              root = dir
            end)
            return root ~= nil
          end,
          cwd = function(_, ctx)
            local client = vim.lsp.get_clients({ bufnr = ctx.buf, name = "oxfmt" })[1]
            return client and client.root_dir
          end,
        },
      },
      formatters_by_ft = {
        ["dockerfile"] = { "dockerfmt" },
        ["javascript"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["javascriptreact"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["typescript"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["typescriptreact"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["vue"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["css"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["scss"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["less"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["html"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["json"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["jsonc"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["json5"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["yaml"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["markdown"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["markdown.mdx"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["graphql"] = { "oxfmt", "prettierd", stop_after_first = true },
        ["handlebars"] = { "oxfmt", "prettierd", stop_after_first = true },
        -- currently prettier-plugin-toml is not configurable, and I don't like
        -- the default formatting
        -- ["toml"] = { "prettier" },
      },
    },
  },
}
