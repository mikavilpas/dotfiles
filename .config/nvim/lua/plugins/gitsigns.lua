---@module "gitsigns"

---@type LazySpec
return {
  "lewis6991/gitsigns.nvim",
  ---@type Gitsigns.Config
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    signs_staged_enable = true,
  },
}
