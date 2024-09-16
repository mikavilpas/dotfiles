---@module "lazy"
---@module "rip-substitute"

---@type LazySpec
return {
  "chrisgrieser/nvim-rip-substitute",
  cmd = "RipSubstitute",
  ---@type ripSubstituteConfig
  opts = {
    prefill = { startInReplaceLineIfPrefill = true },
    regexOptions = {
      startWithFixedStringsOn = true,
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
