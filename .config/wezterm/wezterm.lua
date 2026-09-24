-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
---@type Config
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end
config.default_prog = {
  "/Users/mikavilpas/.local/share/mise/installs/aqua-fish-shell-fish-shell/latest/fish.pkg/Payload/usr/local/bin/fish",
  "-l",
}

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = "AdventureTime"
--
--

--
-- See all system fonts with:
--
-- wezterm ls-fonts --list-system

config.font = wezterm.font("DejaVuSansM Nerd Font Propo")
config.font_size = 19
config.freetype_load_target = "Light"

-- Pin the hinting mode. wezterm's default for this is DPI-dependent:
-- NO_HINTING at >=100 DPI, DEFAULT below it. With a Retina laptop screen and
-- lower-density external monitors, that means glyphs are hinted differently
-- depending on which display the window is on. Pinning it keeps rendering
-- identical everywhere, and matches how macOS itself renders (CoreText
-- essentially ignores hinting and relies on high DPI).
config.freetype_load_flags = "NO_HINTING"

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

-- Default is 16 cells, which cuts most titles off mid-path. The fancy tab bar
-- sizes each tab to its own title, so this is a ceiling rather than a fixed
-- width: short titles stay short, long ones grow up to here.
config.tab_max_width = 40

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
  {
    key = "f",
    mods = "SUPER",
    action = act.Search({ CaseInSensitiveString = "" }),
  },

  { key = "UpArrow", mods = "SUPER", action = act.ScrollToPrompt(-1) },
  { key = "DownArrow", mods = "SUPER", action = act.ScrollToPrompt(1) },

  {
    key = "P",
    mods = "SUPER|SHIFT",
    action = wezterm.action.ActivateCommandPalette,
  },
  {
    -- Open a new window and run `x` (fish function that exits on success)
    -- in the previous pane, so one-off terminals close themselves once
    -- their work is done.
    key = "n",
    mods = "SUPER|SHIFT",
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.SpawnWindow, pane)
      pane:send_text("x\r")
    end),
  },
  {
    -- Same as SUPER|SHIFT n, but spawns a new tab instead of a window.
    key = "t",
    mods = "SUPER|SHIFT",
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.SpawnTab("CurrentPaneDomain"), pane)
      pane:send_text("x\r")
    end),
  },
  {
    -- Open URL with <leader>o
    key = "o",
    mods = "LEADER",
    action = wezterm.action.QuickSelectArgs({
      label = "open url",
      patterns = {
        -- exclude trailing characters that are not part of the URL, such
        -- as the closing ) in markdown links like [text](url)
        "https?://\\S+[^)\\]>\"'.,;:!?\\s]",
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
  {
    key = "Y",
    mods = "LEADER",
    action = wezterm.action.QuickSelectArgs({
      label = "copy mode at identifier",
      patterns = {
        "(?:file://)?[\\w\\._/@-]+:\\d+:\\d+",
        "(?:file://)?[\\w\\._/@-]+",
      },
      action = wezterm.action_callback(function(window, pane)
        local text = window:get_selection_text_for_pane(pane)
        window:perform_action(act.ActivateCopyMode, pane)
        window:perform_action(act.Search({ CaseSensitiveString = text }), pane)
      end),
    }),
  },
}

config.mouse_bindings = {
  {
    event = { Down = { streak = 3, button = "Left" } },
    action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
    mods = "NONE",
  },
}

-- and finally, return the configuration to wezterm
return config
