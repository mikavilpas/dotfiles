---@module "lazy"
---@module "debugprint"

---@type LazySpec
return {
  "https://github.com/andrewferrier/debugprint.nvim",
  keys = {
    { "g?p", desc = "debugprint below" },
    { "g?P", desc = "debugprint above" },
    { "g?v", desc = "debugprint variable below", mode = { "n", "v" } },
    { "g?V", desc = "debugprint variable above", mode = { "n", "v" } },
    { "g?o", desc = "debugprint textobj below" },
    { "g?O", desc = "debugprint textobj above" },
    { "g?d", desc = "delete debug prints" },
  },
  ---@type debugprint.GlobalOptions
  opts = {
    print_tag = "🤔 DEBUGPRINT",
    keymaps = {
      normal = {
        plain_below = "g?p",
        plain_above = "g?P",
        variable_below = "g?v",
        variable_above = "g?V",
        variable_below_alwaysprompt = nil,
        variable_above_alwaysprompt = nil,
        textobj_below = "g?o",
        textobj_above = "g?O",
        toggle_comment_debug_prints = nil,
        delete_debug_prints = "g?d",
      },
      visual = {
        variable_below = "g?v",
        variable_above = "g?V",
      },
    },
    commands = {
      toggle_comment_debug_prints = "ToggleCommentDebugPrints",
      delete_debug_prints = "DeleteDebugPrints",
    },
  },
}
