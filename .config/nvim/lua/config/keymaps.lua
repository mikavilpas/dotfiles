-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

do
  local colors = require("catppuccin.palettes.macchiato")
  local darken = require("catppuccin.utils.colors").darken
  local bg = darken(colors.mauve, 0.5)
  vim.api.nvim_set_hl(0, "Visual", { bg = bg })
end

vim.api.nvim_create_autocmd("FileType", {
  -- always open help buffers in a vertical split
  pattern = { "help", "man" },
  command = "wincmd L",
})

vim.keymap.set({ "t" }, "<esc><esc>", "<Nop>")
vim.keymap.set({ "n" }, "<leader>w", "<Nop>")

vim.keymap.set({ "v" }, "ä", function()
  if require("incr").is_active() then
    -- both c-space (from LazyVim) and a are used for treesitter incremental
    -- selection. It's faster to hit these alternate keys in quick succession.
    -- This way I can quickly select a large node.
    require("incr").increment_selection()
  else
    require("blink.indent.motion").operator("bottom", true)()
  end
end, { desc = "Increment selection" })

vim.keymap.set({ "n" }, "<leader>br", function()
  -- Reopen the current buffer/file to fix LSP warnings being out of sync. For
  -- some reason this seems to fix it.
  local state = {
    file = vim.fn.expand("%"),
    buffer = vim.api.nvim_get_current_buf(),
    scroll = vim.fn.winsaveview(),
  }
  -- save changes and reopen the file
  require("snacks.bufdelete").delete({ buf = state.buffer })

  vim.schedule(function()
    vim.cmd("edit " .. state.file)
    vim.fn.winrestview(state.scroll)
  end)
end, { desc = "Reopen buffer" })

vim.keymap.set({ "v" }, "s", "<Plug>(nvim-surround-visual)")

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "Disable New Line Comment",
})

vim.keymap.set("n", "<leader>qr", function()
  vim.cmd("restart")
end, { desc = ":restart" })

vim.keymap.set("n", "<leader>gd", function()
  require("snacks.picker").lsp_definitions({
    actions = { confirm = "edit_vsplit" },
  })
end, { desc = "Goto definition vsplit 👉🏻" })

vim.keymap.set("n", "<leader>xl", function()
  vim.cmd("luafile %")
  vim.notify("Reloaded lua file", vim.log.levels.INFO)
end, { desc = "Reload file" })

vim.keymap.set("n", "<left>", function()
  local windows = vim.api.nvim_tabpage_list_wins(0)
  local win = windows[1]
  assert(win, "No windows found in the current tabpage")
  vim.api.nvim_win_close(win, true)

  local visible_buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(visible_buffers) do
    if vim.api.nvim_get_option_value("filetype", { buf = buf }) == "snacks_dashboard" then
      -- close it
      require("snacks.bufdelete").delete(buf)
    end
  end
end, { desc = "Close leftmost window" })

-- disable esc j and esc k moving lines accidentally
-- https://github.com/LazyVim/LazyVim/discussions/658
vim.keymap.set("n", "<A-k>", "<esc>k", { desc = "Move up" })
vim.keymap.set("n", "<A-j>", "<esc>j", { desc = "Move down" })
vim.keymap.set("i", "<A-k>", "<esc>gk", { desc = "Move up" })
vim.keymap.set("i", "<A-j>", "<esc>gj", { desc = "Move down" })
vim.keymap.set("v", "<A-k>", "<esc>gk", { desc = "Move up" })
vim.keymap.set("v", "<A-j>", "<esc>gj", { desc = "Move down" })

-- move to previous and next changes in the current file
vim.api.nvim_set_keymap("n", "-", "g;", { noremap = true })
vim.api.nvim_set_keymap("n", "+", "g,", { noremap = true })

-- based mapping section from ThePrimeagen

-- joins lines without moving the cursor
vim.keymap.set("n", "J", "m9J`9", { desc = "Join line" })

-- move screen up and down but keep the cursor in place (less disorienting)
vim.keymap.set("n", "<C-u>", function()
  local screen_height = vim.api.nvim_win_get_height(0)

  vim.cmd("normal! " .. math.floor(screen_height / 2) .. "k")
  vim.cmd("normal! zz")
end, { desc = "Move screen up" })
vim.keymap.set("n", "<C-d>", function()
  local screen_height = vim.api.nvim_win_get_height(0)
  vim.cmd("normal! " .. math.floor(screen_height / 2) .. "j")
  vim.cmd("normal! zz")
end, { desc = "Move screen down" })

-- when searching, move to the next match and center the screen
vim.keymap.set("n", "n", "nzzzv", { desc = "Move to next match" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Move to previous match" })

-- replace whatever is visually selected with the next pasted text, without overwriting the clipboard
vim.keymap.set("x", "p", function()
  require("mini.operators").replace("visual")
end)

-- paste and stay in the same column
vim.keymap.set("n", "p", function()
  local current_column = vim.fn.virtcol(".")
  vim.cmd("normal! p")
  vim.cmd("normal! " .. current_column .. "|")
end)

-- easy navigation between diagnostic items such as errors
vim.keymap.set("n", "<leader>j", function()
  vim.cmd("normal ]d")
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>k", function()
  vim.cmd("normal [d")
end, { desc = "Previous diagnostic" })

-- the same thing for quickfix lists
vim.keymap.set("n", "<leader><down>", function()
  local trouble = require("trouble")
  if trouble.is_open() then
    vim.cmd("Trouble quickfix next")
    vim.cmd("Trouble quickfix jump")
    return
  end
  vim.cmd("silent! cnext")
end, { desc = "Next quickfix item" })
vim.keymap.set("n", "<leader><up>", function()
  local trouble = require("trouble")
  if trouble.is_open() then
    vim.cmd("Trouble quickfix prev")
    vim.cmd("Trouble quickfix jump")
    return
  end
  vim.cmd("silent! cprev")
end, { desc = "Previous quickfix item" })

vim.keymap.set({ "n" }, "<leader>cy", function()
  require("my-nvim-micro-plugins.main").comment_line()
end, { desc = "Comment line", silent = true })

vim.keymap.set({ "v" }, "<f8>", function()
  local current_line = vim.fn.line(".")
  local current_column = vim.fn.virtcol(".")

  vim.cmd("'<,'>sort")
  -- exit visual mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, true, true), "n", true)

  -- restore cursor position
  vim.cmd("normal! " .. current_line .. "G")
  vim.cmd("normal! " .. current_column .. "|")
end, { desc = ":sort", silent = true })

vim.keymap.set({ "v" }, "<leader>cy", function()
  -- do nothing unless we are in visual line mode
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "V" then
    vim.notify("Visual line mode required", vim.log.levels.ERROR)
    return
  end

  local current_column = vim.fn.virtcol(".")
  -- yank the current selection and reactivate it in visual mode
  vim.cmd("normal ygv")

  -- comment the current selection and indent
  vim.cmd("normal gcgv=")

  -- jump to the end of the last visual selection and paste the yanked text
  vim.cmd("normal `>p")
  vim.cmd("normal " .. current_column .. "|")
end, { desc = "Comment line", silent = true })

vim.keymap.set("n", "<leader>fyr", function()
  local thisfile = vim.fn.expand("%:p")
  assert(thisfile ~= "", "Error getting the file path. Maybe this file is not saved yet?")

  local result = vim.system({ "git", "ls-files", "--full-name", thisfile }):wait(2000)
  assert(result.code == 0, "Error getting git relative path: " .. result.stderr)
  assert(result.stdout)
  assert(type(result.stdout) == "string")
  assert(#result.stdout > 0)

  local filepath = vim.split(result.stdout, "\n")[1]
  vim.notify("Copied " .. filepath, vim.log.levels.INFO)

  vim.fn.setreg("+", filepath)
end, { desc = "Copy git relative path to clipboard" })

-- full path
vim.keymap.set("n", "<leader>fyp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied full file path to the clipboard", vim.log.levels.INFO)
end, { desc = "Copy full path to clipboard" })

-- just filename
vim.keymap.set("n", "<leader>fyf", function()
  vim.fn.setreg("+", vim.fn.expand("%:t"))
  vim.notify("Copied " .. vim.fn.expand("%:t") .. " to the clipboard", vim.log.levels.INFO)
end, { desc = "Copy filename to the clipboard" })

-- directory of the current file
vim.keymap.set("n", "<leader>fyd", function()
  vim.fn.setreg("+", vim.fn.expand("%:h"))
end, { desc = "Copy directory to clipboard" })

vim.keymap.set("n", "(", function()
  require("snacks.words").jump(-1, true)
end, { desc = "Jump to previous thing" })
vim.keymap.set("n", ")", function()
  require("snacks.words").jump(1, true)
end, { desc = "Jump to next thing" })

vim.keymap.set("v", "<leader>ä", function()
  local selection = require("my-nvim-micro-plugins.main").get_visual()
  vim.cmd("= " .. selection)
end, { desc = "Evaluate visual selection as lua" })

-- Remap y to ygv<esc> in visual mode so the cursor does not jump back to where
-- you started the selection.
-- https://www.reddit.com/r/neovim/comments/13y3thq/comment/jmm7tut/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
vim.keymap.set("v", "y", "ygv<esc>")

vim.keymap.set("n", "<backspace>", function()
  pcall(function()
    vim.cmd("LspOxlintFixAll")
  end)
  pcall(function()
    vim.cmd("LspEslintFixAll")
  end)

  vim.cmd("silent! wall")
end, { desc = "Save all files", silent = true })
vim.keymap.set({ "n", "v" }, "<up>", "<cmd>Yazi<cr>", { desc = "Open yazi" })

vim.keymap.set("n", "'", function()
  local found = false
  vim.lsp.buf.code_action({
    apply = true,
    filter = function(action)
      if found then
        return false
      end
      local match = action.title:find("Update import") ~= nil
        or action.title:find("Add import") ~= nil
        -- rust-analyzer import action
        or action.title:find("Import `")
      local correct_kind = action.kind == "quickfix"

      local ok = match and correct_kind
      if ok then
        found = true
        vim.notify("👍🏻: " .. action.title, vim.log.levels.INFO)
      end
      return ok
    end,
  })
end)

do
  ---@param pane number
  function LoadWeztermOutputIntoQuickfix(pane)
    -- Load wezterm output into quickfix
    local wezterm_output = vim.fn.system("wezterm cli get-text --pane-id " .. pane)
    local lines = vim.split(wezterm_output, "\n")
    local items = {}
    for _, line in ipairs(lines) do
      if line ~= "" then
        -- TODO need to adjust the regex
        local filename, lnum = string.match(line, "([^:]+):?(%d*)")
        assert(filename, "Failed to parse wezterm output: " .. line)
        ---@diagnostic disable-next-line: assign-type-mismatch
        lnum = tonumber(lnum) or 1
        if vim.fn.filereadable(filename) == 1 then
          table.insert(items, {
            filename = filename,
            lnum = lnum,
            col = 1,
            text = line,
          })
        else
          -- vim.notify("File not found: " .. filename, vim.log.levels.WARN)
        end
      end
    end
    if #items == 0 then
      vim.notify("No valid items found in wezterm output " .. wezterm_output, vim.log.levels.WARN)
      return
    end

    vim.cmd("Trouble quickfix close")
    vim.fn.setqflist({}, "r", {
      title = "Wezterm Output",
      items = items,
    })
    vim.cmd("Trouble quickfix last")
    vim.cmd("Trouble quickfix jump")
  end

  do
    ---@type number|nil
    local last_pane = nil

    ---@param on_selected fun(pane_id: number)
    function ChooseWeztermPane(on_selected)
      -- select pane
      local wezterm_output = vim.fn.system("wezterm cli list")
      if vim.v.shell_error ~= 0 then
        vim.notify("Failed to get wezterm output", vim.log.levels.ERROR)
        return
      end

      require("snacks.picker").select(vim.split(wezterm_output, "\n"), nil, function(item)
        ---@cast item string
        --       WINID TABID PANEID WORKSPACE SIZE    TITLE                                CWD
        -- item="   41   192    205 default   148x108 w pnpm eslint --fix ~/g/tui-sandbox file://br-g4kn2711j0/Users/mikavilpas/git/tui-sandbox               "
        local words = vim.split(item, "%s+")
        local pane_id = tonumber(words[4])
        assert(pane_id, "Failed to parse wezterm output as number: " .. item)
        on_selected(pane_id)
      end)
    end
    vim.keymap.set("n", "<leader>an", function()
      if last_pane then
        LoadWeztermOutputIntoQuickfix(last_pane)
      else
        ChooseWeztermPane(function(pane_id)
          last_pane = tonumber(pane_id)
          LoadWeztermOutputIntoQuickfix(pane_id)
        end)
      end
    end, { desc = "Load wezterm output into quickfix" })

    vim.keymap.set("n", "<leader>aN", function()
      ChooseWeztermPane(function(pane_id)
        last_pane = tonumber(pane_id)
        LoadWeztermOutputIntoQuickfix(pane_id)
      end)
    end, { desc = "Load wezterm output from new pane" })
  end
end
