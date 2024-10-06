---@module "gitsigns"

---@module "lazy"
---@type LazySpec
return {
  "lewis6991/gitsigns.nvim",
  -- https://github.com/lewis6991/gitsigns.nvim
  ---@type Gitsigns.Config
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    signs_staged_enable = true,

    -- also see https://github.com/LazyVim/LazyVim/blob/3dbace941ee935c89c73fd774267043d12f57fe2/lua/lazyvim/plugins/editor.lua#L247
  },
}
