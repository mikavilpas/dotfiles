-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end
config.default_prog = { "/opt/homebrew/bin/fish", "-l" }

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = "AdventureTime"
--
--

-- You can download the newest version of this font (it gets updates) with:
--
-- brew install font-dejavu-sans-mono-nerd-font
--
-- See all system fonts with:
--
-- wezterm ls-fonts --list-system

config.font = wezterm.font("DejaVuSansM Nerd Font Propo")
config.font_size = 19
config.freetype_load_target = "Light"

-- https://github.com/folke/dot/blob/1007fc65738ad1f7a3e9c91432430017a6878378/config/wezterm/wezterm.lua

config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

config.visual_bell = {
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 150,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 150,
}
config.colors = {
	visual_bell = "#303030",
}

-- config.color_scheme = "Tokyo Night"
-- config.color_scheme = "Catppuccin Latte"
config.color_scheme = "Catppuccin Macchiato"
-- config.color_scheme = "Catppuccin Frappe"
-- config.color_scheme = "Catppuccin Mocha"

-- fix not being able to write "|" on a mac
-- https://wezfurlong.org/wezterm/config/keyboard-concepts.html?h=mac#macos-left-and-right-option-key
config.send_composed_key_when_left_alt_is_pressed = false

-- timeout_milliseconds defaults to 1000 and can be omitted
-- https://wezfurlong.org/wezterm/config/keys.html#leader-key
config.leader = { key = "a", mods = "SUPER", timeout_milliseconds = 1000 }

config.scrollback_lines = 5000

local act = wezterm.action
config.keys = {
	-- Clears the scrollback and viewport leaving the prompt line the new first line.
	{
		key = "k",
		mods = "SUPER",
		action = act.ClearScrollback("ScrollbackAndViewport"),
	},
	{
		key = "+",
		mods = "SUPER",
		action = act.IncreaseFontSize,
	},

	-- https://wezfurlong.org/wezterm/scrollback.html#enabledisable-scrollbar
	{ key = "f", mods = "SUPER", action = act.Search({ CaseInSensitiveString = "" }) },

	{ key = "UpArrow", mods = "SUPER", action = act.ScrollToPrompt(-1) },
	{ key = "DownArrow", mods = "SUPER", action = act.ScrollToPrompt(1) },

	{
		key = "P",
		mods = "SUPER|SHIFT",
		action = wezterm.action.ActivateCommandPalette,
	},
	{
		-- Open URL with <leader>o
		key = "o",
		mods = "LEADER",
		action = wezterm.action.QuickSelectArgs({
			label = "open url",
			patterns = {
				"https?://\\S+",
			},
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wezterm.log_info("opening: " .. url)
				-- -n opens in a new window
				wezterm.open_with(url)
			end),
		}),
	},
	{
		key = "y",
		mods = "LEADER",
		action = wezterm.action.QuickSelectArgs({
			label = "copy file path",
			patterns = {
				-- test cases:
				--
				-- src/api/api-client-integration.test.ts:56:15
				-- /Users/mikavilpas/project/file.test.ts',
				-- /Users/mikavilpas/project/file.test.ts:38:5',
				-- /Users/mikavilpas/@project/file.test.ts:38:5',
				-- file:///Users/mikavilpas/project/node_modules/@vitest/runner/dist/index.js:563:22',
				-- /Users/mikavilpas/git/blink-ripgrep.nvim/integration-tests/test-environment
				"(?:file://)?[\\w\\._/@-]+:\\d+:\\d+",
				"(?:file://)?[\\w\\._/@-]+",
			},
			action = wezterm.action.CopyTo("ClipboardAndPrimarySelection"),
		}),
	},
}

-- integration with nvim and zen-mode
-- https://github.com/folke/zen-mode.nvim?tab=readme-ov-file#wezterm
wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

config.mouse_bindings = {
	{
		event = { Down = { streak = 3, button = "Left" } },
		action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
		mods = "NONE",
	},
}

-- and finally, return the configuration to wezterm
return config
