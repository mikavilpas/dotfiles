return {
  "ggandor/leap.nvim",
  enabled = true,
  keys = {
    -- Jump to the beginnings of lines
    { "<leader>y", mode = { "n", "v" }, "<cmd>lua LeapLines()<CR>", desc = "Leap Lines" },
  },
  config = function(_, opts)
    local leap = require("leap")
    for k, v in pairs(opts) do
      leap.opts[k] = v
    end

    -- don't add the default keybindings
    --
    -- Improve the colors
    vim.api.nvim_set_hl(0, "LeapBackdrop", {})
    vim.api.nvim_set_hl(0, "LeapMatch", {
      -- For light themes, set to 'black' or similar.
      fg = "white",
      bold = true,
      nocombine = true,
    })

    vim.api.nvim_set_hl(0, "LeapLabelPrimary", {
      fg = "pink",
      bold = true,
      nocombine = true,
    })
    vim.api.nvim_set_hl(0, "LeapLabelSecondary", {
      fg = "blue",
      bold = true,
      nocombine = true,
    })
    -- Try it without this setting first, you might find you don't even miss it.
    require("leap").opts.highlight_unlabeled_phase_one_targets = true

    -- Jump to the beginnings of lines
    -- https://gist.github.com/ggandor/24b563e4d37eddedc0b50403d4345941
    local function get_targets(winid)
      local wininfo = vim.fn.getwininfo(winid)[1]
      local cur_line = vim.fn.line(".")
      -- Get targets.
      local targets = {}
      local lnum = wininfo.topline
      while lnum <= wininfo.botline do
        -- Skip folded ranges.
        local fold_end = vim.fn.foldclosedend(lnum)
        if fold_end ~= -1 then
          lnum = fold_end + 1
        else
          if lnum ~= cur_line then
            table.insert(targets, { pos = { lnum, 1 } })
          end
          lnum = lnum + 1
        end
      end
      -- Sort them by vertical screen distance from cursor.
      local cur_screen_row = vim.fn.screenpos(winid, cur_line, 1)["row"]
      local function screen_rows_from_cursor(t)
        local t_screen_row = vim.fn.screenpos(winid, t.pos[1], t.pos[2])["row"]
        return math.abs(cur_screen_row - t_screen_row)
      end
      table.sort(targets, function(t1, t2)
        return screen_rows_from_cursor(t1) < screen_rows_from_cursor(t2)
      end)
      if #targets >= 1 then
        return targets
      end
    end

    -- Map this function to your preferred key.
    function LeapLines()
      local winid = vim.api.nvim_get_current_win()
      require("leap").leap({ targets = get_targets(winid), target_windows = { winid } })
    end
  end,
}
