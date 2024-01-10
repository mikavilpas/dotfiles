return {
  "ggandor/leap.nvim",
  enabled = true,
  config = function(_, opts)
    local leap = require("leap")
    for k, v in pairs(opts) do
      leap.opts[k] = v
    end

    -- don't add the default keybindings
  end,
}
