---@module "lazy"
---@type LazySpec
return {
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node

      ls.add_snippets("gitcommit", {
        s("issue", {
          t("**Issue:** "),
          i(1),
          t({
            "",
            "",
            "**Solution:**",
            "",
            "",
          }),
        }),
      })
    end,
  },
}
