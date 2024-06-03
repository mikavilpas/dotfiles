---@type LazySpec
return {
  "Canop/nvim-bacon",
  -- cmd = { "BaconLoad", "BaconShow", "BaconList", "BaconPrevious", "BaconNext" },
  opts = {
    quickfix = {
      enabled = true, -- true to populate the quickfix list with bacon errors and warnings
      event_trigger = true, -- triggers the QuickFixCmdPost event after populating the quickfix list
    },
  },
  keys = {
    {
      "<leader>!",
      function()
        local bacon = require("bacon")
        bacon.bacon_load()
        bacon.bacon_next()
      end,
    },
  },
  -- ft = { "rs" }, -- rust
  -- config = function()
  --   require("bacon").setup({
  --     quickfix = {
  --       enabled = true,
  --       event_trigger = true,
  --     },
  --   })
  -- end,
  -- keys = {
  --   {
  --     "<space>.",
  --     cmd = function()
  --       vim.cmd("BaconLoad")
  --       vim.cmd("write")
  --       vim.cmd("BaconNext")
  --     end,
  --   },
  --   {
  --     "<space>t",
  --     cmd = "BaconList",
  --   },
}
