---@diagnostic disable: undefined-global
-- Starship prompt plugin for yazi
-- https://github.com/Rolv-Apneseth/starship.yazi
require("starship"):setup()

-- This plugin provides cross-instance yank ability, which means you can yank
-- files in one instance, and then paste them in another instance.
require("session"):setup({
	sync_yanked = true,
})

require("yaziline"):setup()

THEME.git_added_sign = ""
THEME.git_modified_sign = ""
THEME.git_ignored_sign = ""
THEME.git_deleted_sign = ""
THEME.git_untracked_sign = ""
-- TODO what is this?
-- THEME.git_updated_sign = ""

-- https://github.com/yazi-rs/plugins/tree/main/git.yazi
require("git"):setup({})
