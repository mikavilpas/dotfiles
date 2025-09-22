vim.filetype.add({
  pattern = {
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml.ghaction",
    [".env.*"] = "sh.dotenv",
  },
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
