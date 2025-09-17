vim.filetype.add({
  pattern = {
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.ghaction",
  },
})

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        ghaction = { "actionlint" },
      },
    },
  },
}
