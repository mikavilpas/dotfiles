-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = "AdventureTime"
--
--

config.font = wezterm.font("DejaVuSansMono NF", { weight = "Regular" })
config.font_size = 13

-- from https://github.com/wez/wezterm/issues/4051#issue-1820224035
if wezterm.gui.get_appearance():find("Dark") then
	-- config.color_scheme = "Catppuccin Mocha"
	-- config.color_scheme = "Tartan (terminal.sexy)"
	config.color_scheme = "Tokyo Night"
else
	-- config.color_scheme = "Catppuccino Latte"
	-- config.color_scheme = "tokyonight-day"
	config.color_scheme = "Papercolor Light (Gogh)"
end

-- and finally, return the configuration to wezterm
return config
