---@type LazySpec
return {
  "tzachar/highlight-undo.nvim",
  -- Highlight changed text after Undo / Redo operations. Purely lua / nvim api
  -- implementation, no external dependencies needed.
  --
  -- https://github.com/tzachar/highlight-undo.nvim
  event = "BufRead",
}
