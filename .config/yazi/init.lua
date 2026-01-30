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

-- https://github.com/yazi-rs/plugins/tree/main/git.yazi
th.git = th.git or {}

th.git.added = ui.Style():fg("blue")
th.git.added_sign = ""

th.git.deleted = ui.Style():fg("red"):bold()
th.git.deleted_sign = ""

th.git.ignored = ui.Style():fg("gray")
th.git.ignored_sign = ""

th.git.modified = ui.Style():fg("green")
th.git.modified_sign = ""

th.git.untracked = ui.Style():fg("gray")
th.git.untracked_sign = ""

th.git.updated = ui.Style():fg("green")
th.git.updated_sign = ""

require("git"):setup()
