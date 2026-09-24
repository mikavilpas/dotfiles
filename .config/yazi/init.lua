---@diagnostic disable: undefined-global
-- Starship prompt plugin for yazi
-- https://github.com/Rolv-Apneseth/starship.yazi
-- ./plugins/starship.yazi/
require("starship"):setup()

require("easyjump"):setup()

-- This plugin provides cross-instance yank ability, which means you can yank
-- files in one instance, and then paste them in another instance.
require("session"):setup({
  sync_yanked = true,
})

require("git"):setup()

if os.getenv("YAZI_NVIM_ID") ~= nil then
  pcall(function()
    require("nvim").setup()
  end)
end
