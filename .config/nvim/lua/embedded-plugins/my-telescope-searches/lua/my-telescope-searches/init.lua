local M = {}

-- Copy the relative path of the selected file to the system clipboard.
-- Can only be used in a file picker.
function M.my_copy_relative_path(prompt_bufnr)
  local current_file_dir = vim.fn.expand("#:p:h")
  if current_file_dir == nil then
    error("no current_file_dir, cannot do anything")
  end

  local Path = require("plenary.path")
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")
  local telescopeUtils = require("telescope.utils")

  local selection = action_state.get_selected_entry()

  if selection == nil then
    error("no selection, cannot continue")
  end

  local selected_file = Path:new(selection.cwd, selection.value):__tostring()

  local stdout, ret, stderr =
    telescopeUtils.get_os_command_output({ "grealpath", "--relative-to", current_file_dir, selected_file })

  if ret ~= 0 or stdout == nil or stdout == "" then
    print(vim.inspect(stderr))
    error("error running command, exit code " .. ret)
  end

  local relative_path = stdout[1]
  vim.fn.setreg("*", relative_path)
  -- display a message with the relative path
  vim.api.nvim_echo({ { "Copied: ", "Normal" }, { relative_path, "String" } }, true, {})

  actions.close(prompt_bufnr)
end

---@return string?
function M.find_project_root()
  local current_file_dir = vim.fn.expand("%:p:h")
  local stdout, ret =
    require("telescope.utils").get_os_command_output({ "git", "rev-parse", "--show-toplevel" }, current_file_dir)
  if ret ~= 0 then
    error("could not determine top level git directory")
  end
  local cwd = stdout[1]

  return cwd
end

-- Find files from the root of the current repository.
-- Does not search parents if we're currently in a submodule.
function M.my_find_file_in_project()
  local cwd = M.find_project_root()

  vim.notify("searching in " .. cwd)
  require("telescope.builtin").find_files({
    find_command = { "fd", "--hidden" },
    cwd = cwd,
  })
end

-- Search for the current visual mode selection.
-- Like the built in live_grep but with the options that I like, plus some
-- documentation on how the whole thing works.
function M.my_live_grep()
  --
  -- search for the current visual mode selection
  -- https://github.com/nvim-telescope/telescope.nvim/issues/2497#issuecomment-1676551193
  local function get_visual()
    vim.cmd('noautocmd normal! "vy"')
    local text = vim.fn.getreg("v")
    vim.fn.setreg("v", {})

    text = string.gsub(text or "", "\n", "")
    if #text > 0 then
      return text
    else
      return ""
    end
  end

  local selection = get_visual()

  local cwd = M.find_project_root()
  vim.notify("searching in " .. cwd)

  -- pro tip: search for an initial, wide result with this, and then hit
  -- c-spc to use fuzzy matching to narrow it down
  require("telescope.builtin").live_grep({
    cwd = cwd,
    default_text = selection,
    only_sort_text = true,
    additional_args = function()
      -- --pcre2
      -- The --pcre2 flag in ripgrep is used to enable the PCRE2 (Perl
      -- Compatible Regular Expressions) engine for pattern matching.
      -- PCRE2 is an optional feature in ripgrep that provides more
      -- advanced regex features such as look-around and backreferences,
      -- which are not supported by ripgrep's default regex engine 134.

      -- --smart-case
      -- This flag instructs ripgrep to searches case insensitively if
      -- the pattern is all lowercase. Otherwise, ripgrep will search
      -- case sensitively.

      -- NOTE: the ~/.gitignore and ~/.rgignore files will have an effect on
      -- what is ignored
      -- https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#automatic-filtering
      return { "--pcre2", "--hidden", "--smart-case" }
    end,
  })
end

return M
