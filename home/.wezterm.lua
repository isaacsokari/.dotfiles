---@diagnostic disable: no-unknown
local wezterm = require("wezterm")

-- @see https://wezfurlong.org/wezterm/config/lua/config/index.html
local config = wezterm.config_builder()

-- @see https://wezfurlong.org/wezterm/colorschemes/index.html
config.color_scheme = "catppuccin-mocha"

config.font_size = 14.0
config.font = wezterm.font_with_fallback({
	"Cascadia Code",
	"JetBrains Mono",
})
config.line_height = 1.1

config.hide_tab_bar_if_only_one_tab = true
config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.95
config.macos_window_background_blur = 10

-- disable ligatures
-- @see https://wezfurlong.org/wezterm/config/font-shaping.html
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- remove window padding
-- @see https://wezfurlong.org/wezterm/config/lua/config/window_padding.html
config.window_padding = {
	left = "0.5cell",
	right = "0.5cell",
	top = "0.5cell",
	bottom = "0",
}

config.native_macos_fullscreen_mode = true

-- @see https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html#available-key-assignments
config.keys = {
	{
		key = "Enter",
		mods = "SUPER",
		action = wezterm.action.ToggleFullScreen,
	},
}

return config
