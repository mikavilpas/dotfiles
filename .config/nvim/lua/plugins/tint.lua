---@type LazySpec
return {
  -- Dim inactive windows in Neovim using window-local highlight namespaces.
  -- https://github.com/levouh/tint.nvim
  "levouh/tint.nvim",
  event = "VeryLazy",

  config = function(_)
    require("tint").setup({
      tint_background_colors = true,
      transforms = {
        function(r, g, b, hl_group_info)
          -- I have set catppuccin tod dim the background colors of inactive
          -- windows. That causes the text for LspInlayHints to become much
          -- more readable. This makes the text to be dimmed properly
          if hl_group_info.hl_group_name == "LspInlayHint" then
            local amt = 15
            return r - amt, g - amt, b - amt
          end

          return r, g, b
        end,
      },
    })
  end,
}
