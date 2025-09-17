---@module "lazy"
---@type LazySpec
return {
  {
    -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-operators.md
    "nvim-mini/mini.operators",
    version = "*",
    opts = {
      exchange = {
        -- mnemonic: l for "last"
        prefix = "gl",
      },
    },
  },

  {
    "nvim-mini/mini.ai",
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
  { "nvim-mini/mini.cursorword", config = true },
}
