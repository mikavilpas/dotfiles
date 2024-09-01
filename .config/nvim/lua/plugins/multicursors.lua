---@module "lazy"
---
---@type LazySpec
return {
  "jake-stewart/multicursor.nvim",
  config = function()
    local mc = require("multicursor-nvim")

    mc.setup()

    -- use MultiCursorCursor and MultiCursorVisual to customize
    -- additional cursors appearance
    vim.cmd.hi("link", "MultiCursorCursor", "Cursor")
    vim.cmd.hi("link", "MultiCursorVisual", "Visual")

    vim.keymap.set("n", "<leader>mc", function()
      if mc.hasCursors() then
        mc.clearCursors()
      end
    end, { desc = "clear all cursors" })

    vim.keymap.set({ "n", "v" }, "<leader>ma", function()
      mc.addCursor("*")
    end, { desc = "add a cursor and jump to the next word under cursor" })

    -- jump to the next word under cursor but do not add a cursor
    vim.keymap.set({ "n", "v" }, "<leader>ms", function()
      mc.skipCursor("*")
    end, { desc = "skip and jump to the next word under cursor" })

    vim.keymap.set({ "n", "v" }, "<leader>mj", mc.nextCursor, { desc = "jump to previous cursor" })
    vim.keymap.set({ "n", "v" }, "<right>mk", mc.prevCursor, { desc = "jump to next cursor" })
    vim.keymap.set({ "n", "v" }, "<leader>mx", mc.deleteCursor, { desc = "delete cursor" })
    vim.keymap.set({ "n", "v" }, "<leader>ma", mc.alignCursors, { desc = "align cursors" })

    vim.keymap.set({ "v" }, "I", function()
      require("my-nvim-micro-plugins.multicursors").add_multicursors_at_line_starts()
    end)

    vim.keymap.set({ "v" }, "A", function()
      require("my-nvim-micro-plugins.multicursors").add_multicursors_at_line_ends()
    end)
  end,
}
