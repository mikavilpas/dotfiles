---@type LazySpec
return {
  -- characterize.vim: Unicode character metadata
  -- https://github.com/tpope/vim-characterize
  "tpope/vim-characterize",
  lazy = true,
  keys = { { "ga", "<Plug>(characterize)", desc = "Inspect the current character" } },
}
