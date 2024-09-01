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

    local function get_current_visual_selection_line_numbers()
      local mode = vim.fn.mode()

      -- Ensure we're in Visual mode (either character, line, or block)
      if mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V" or mode:sub(1, 1) == "\22" then
        -- Get the line numbers of the start and end of the selection
        local start_line = vim.fn.line("v")
        local end_line = vim.fn.line(".")

        -- Sort the lines to make sure start_line is always less than or equal to end_line
        if start_line > end_line then
          start_line, end_line = end_line, start_line
        end

        return start_line, end_line
      end
    end

    ---@param start_line number
    ---@param end_line number
    ---@param motion? string
    local function add_line_multicursors(start_line, end_line, motion)
      -- return to normal mode from visual mode
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "x", false)

      vim.cmd("normal! " .. start_line .. "G")
      if motion then
        vim.cmd("normal! " .. motion)
      end

      for _ = start_line, end_line - 1, 1 do
        mc.addCursor("j" .. (motion or ""))
      end
    end

    vim.keymap.set({ "v" }, "I", function()
      local mode = vim.fn.mode()
      local is_visual_line = mode:sub(1, 1) == "V"
      local is_visual_block = mode:sub(1, 1) == "\22"

      local start_line, end_line = get_current_visual_selection_line_numbers()

      if is_visual_line then
        add_line_multicursors(start_line, end_line, "_")
      elseif is_visual_block then
        add_line_multicursors(start_line, end_line)
      end
    end)
  end,
}
