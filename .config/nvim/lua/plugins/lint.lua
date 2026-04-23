vim.filetype.add({
  pattern = {
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.ghaction",
    [".env.*"] = "sh.dotenv",
  },
})

-- nvim-lint's actionlint runs from vim.fn.getcwd() with no -config-file, so
-- `.github/actionlint.yaml` is only found when nvim's cwd happens to be the
-- repo root. Point actionlint at the repo root per-buffer instead.
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  callback = function(ev)
    if vim.bo[ev.buf].filetype ~= "yaml.ghaction" then
      return
    end
    if not package.loaded.lint then
      return
    end
    local root = vim.fs.root(ev.buf, { ".git" })
    if root then
      require("lint").linters.actionlint.cwd = root
    end
  end,
})

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        ghaction = { "actionlint" },
        ["sh.dotenv"] = { "dotenv_linter" },
      },
    },
  },
}
