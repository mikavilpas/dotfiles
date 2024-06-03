-- Starship prompt plugin for yazi
-- https://github.com/Rolv-Apneseth/starship.yazi
require("starship"):setup()

-- This plugin provides cross-instance yank ability, which means you can yank
-- files in one instance, and then paste them in another instance.
require("session"):setup({
	sync_yanked = true,
})
