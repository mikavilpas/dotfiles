---@type LazySpec
return {
  "folke/todo-comments.nvim",
  -- ✅ Highlight, list and search todo comments in your projects
  -- https://github.com/folke/todo-comments.nvim
  opts = {
    highlight = {
      pattern = { [[.*<(KEYWORDS)\s*]] }, -- pattern or table of patterns, used for highlighting (vim regex)
    },

    search = {
      pattern = {
        [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
      },
    },
  },
}
