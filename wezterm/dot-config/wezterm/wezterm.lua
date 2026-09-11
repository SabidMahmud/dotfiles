local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.term = "xterm-256color"
-- config.default_prog = {}

config.window_decorations = "RESIZE" -- No title bar, but resizable
config.window_background_opacity = 0.99
config.enable_tab_bar = false
config.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 8,
}

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12.0

-- Load theme colors
local success, theme = pcall(require, "theme")
if success and type(theme) == "table" and theme.colors then
	config.colors = theme.colors
end

config.keys = {
	{ key = "F11", action = wezterm.action.ToggleFullScreen },
}

return config
