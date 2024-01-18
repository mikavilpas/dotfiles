-- https://github.com/gsuuon/tshjkl.nvim
return {
  -- "gsuuon/tshjkl.nvim",
  dir = "/Users/mikavilpas/git/tshjkl.nvim",
  opts = {
    keymaps = {
      toggle = "<leader>n",
      toggle_outer = "<leader>v",
    },

    select_current_node = false,

    marks = {
      parent = { -- these are extmark options (:h nvim_buf_set_extmark)
        -- you could add e.g. virt_text, sign_text
        hl_group = "Boolean",
        virt_text = { { "h", { "ModeMsg", "Cursor" } } },
        virt_text_pos = "overlay",
      },
      child = {
        hl_group = "Error",
        virt_text = { { "l", { "ModeMsg", "Cursor" } } },
        virt_text_pos = "overlay",
      },
      next = {
        hl_group = "WarningFloat",
        virt_text = { { "j", { "ModeMsg", "Cursor" } } },
        virt_text_pos = "overlay",
      },
      prev = {
        hl_group = "InfoFloat",
        virt_text = { { "k", { "ModeMsg", "Cursor" } } },
        virt_text_pos = "overlay",
      },
      current = {
        hl_group = "Substitute",
      },
    },
  },
}
