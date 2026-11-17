---@module "lazy"
---@module "nvim-lspconfig"
---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- v2026.10.18: mise lsp: a language server for mise.toml
      -- https://github.com/jdx/mise/releases/tag/v2026.10.18
      -- https://github.com/jdx/mise/pull/14744
      --
      -- It only handles files that mise loads as configs (mise.toml,
      -- mise.<env>.toml, conf.d/*.toml, ...) and ignores Cargo.toml,
      -- pyproject.toml and other TOML files, so you can attach it to the TOML
      -- filetype. Configs are parsed but never rendered, and it makes no
      -- network requests, so opening an untrusted file runs nothing. Clients
      -- can turn off formatting, hover, completion, definition, references or
      -- rename with initializationOptions.
      vim.lsp.config("mise", {
        cmd = { "mise", "lsp" },
        filetypes = { "toml" },
        root_markers = { "mise.toml", ".mise.toml", ".git" },
      })
      vim.lsp.enable("mise")
    end,
  },
}
