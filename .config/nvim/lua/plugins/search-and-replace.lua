---@module "lazy"
---@module "rip-substitute.config"

---@type LazySpec
return {
  "chrisgrieser/nvim-rip-substitute",
  cmd = "RipSubstitute",
  ---@type RipSubstitute.Config | {}
  opts = {
    popupWin = {
      disableCompletions = false,
    },
    prefill = {
      startInReplaceLineIfPrefill = true,
      alsoPrefillReplaceLine = true,
    },
    regexOptions = {
      startWithFixedStringsOn = true,
    },
    editingBehavior = {
      autoCaptureGroups = true,
    },
  },
  keys = {
    {
      "<leader>r",
      function()
        require("rip-substitute").sub()
      end,
      mode = { "n", "x" },
      desc = " rip substitute",
    },
  },
}
