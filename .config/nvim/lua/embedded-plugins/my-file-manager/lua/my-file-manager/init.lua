local M = {}

function M.open_file_manager()
  local Terminal = require("toggleterm.terminal").Terminal

  local buf_name = vim.api.nvim_buf_get_name(0)
  local buf_dir = vim.fn.fnamemodify(buf_name, ":p:h")

  local term = Terminal:new({
    cmd = "yazi " .. buf_dir,
    direction = "float",
    close_on_exit = true,
  })

  term:open()
end

return M
