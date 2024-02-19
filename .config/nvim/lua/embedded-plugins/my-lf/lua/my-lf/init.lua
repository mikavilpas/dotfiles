local Util = require("lazyvim.util")

local M = {}

function M.open_lf()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local buf_dir = vim.fn.fnamemodify(buf_name, ":p:h")
  Util.terminal({ "lf", "-single", buf_name }, { cwd = buf_dir, esc_esc = false, ctrl_hjkl = false })
end

return M
