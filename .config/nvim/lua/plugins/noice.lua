---@type LazySpec
return {
  -- 💥 Highly experimental plugin that completely replaces the UI for
  -- messages, cmdline and the popupmenu.
  -- https://github.com/folke/noice.nvim?tab=readme-ov-file
  "folke/noice.nvim",
  ---@type NoiceConfig
  opts = {
    ---@type NoicePresets
    presets = {
      lsp_doc_border = true,

      -- https://github.com/nicknisi/dotfiles/blob/3a394aa71ab034502e8866a442be22d78f1556ee/config/nvim/lua/plugins/noice.lua#L7
      long_message_to_split = true, -- long messages will be sent to a split
      cmdline_output_to_split = true,
    },
    lsp = {
      signature = {
        enabled = false,
      },
    },

    routes = {
      -- disable some annoying messages popping up. I hate them!

      { filter = { find = "No information available" }, opts = { stop = true } },
      { filter = { find = "fewer lines;" }, opts = { skip = true } },
      { filter = { find = "more line;" }, opts = { skip = true } },
      { filter = { find = "more lines;" }, opts = { skip = true } },
      { filter = { find = "less;" }, opts = { skip = true } },
      { filter = { find = "change;" }, opts = { skip = true } },
      { filter = { find = "changes;" }, opts = { skip = true } },
      { filter = { find = "indent" }, opts = { skip = true } },
      { filter = { find = "move" }, opts = { skip = true } },
      { filter = { find = "move" }, opts = { skip = true } },

      -- Disable "file_path" AMOUNT_OF_LINESL, AMOUNT_OF_BYTESB message
      -- https://github.com/KoalaVim/KoalaVim/blob/e4649e74a1838e6a4a1a55a72e58280064bb909c/lua/KoalaVim/misc/noice_routes.lua#L6
      { filter = { event = "msg_show", kind = "", find = '"[%w%p]+" %d+L, %d+B' }, opts = { skip = true } },
    },
  },
}
