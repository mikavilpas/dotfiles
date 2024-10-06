---@module "lazy"
---@type LazySpec
return {
  {
    "echasnovski/mini.indentscope",
    -- https://github.com/echasnovski/mini.indentscope
    opts = {
      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        -- Textobjects
        object_scope = "",
        object_scope_with_border = "",

        -- Motions (jump to respective border line; if not present - body line)
        goto_top = "",
        goto_bottom = "",
      },
      draw = {
        delay = 300,
        animation = function()
          -- this is the implementation from the plugin
          return 0
        end,
      },
    },
  },
  {
    "echasnovski/mini.ai",
    opts = {
      custom_textobjects = {
        i = "",
      },
    },
  },
  {
    -- Usage
    -- This plugin defines two new text objects. These are very similar - they differ only in whether they include the line below the block or not.
    -- Key bindings	Description
    -- <count>ai An Indentation level and line above.
    -- <count>ii Inner Indentation level (no line above).
    -- <count>aI An Indentation level and lines above/below.
    -- <count>iI Inner Indentation level (no lines above/below).
    "michaeljsmith/vim-indent-object",
    event = "BufRead",
  },
  { "echasnovski/mini.cursorword", config = true },
}
