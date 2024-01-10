return {
  "ggandor/leap.nvim",
  enabled = true,
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
  end,
}
