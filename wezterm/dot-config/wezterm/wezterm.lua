local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.term = "xterm-256color"
-- config.default_prog = {}

config.window_decorations = "RESIZE" -- No title bar, but resizable
config.window_background_opacity = 0.95
config.enable_tab_bar = false
config.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 8,
}

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14.0

-- Load theme colors
local success, theme = pcall(require, "theme")
if success and type(theme) == "table" and theme.colors then
	config.colors = theme.colors
end

-- Load font configuration (managed by font-switch)
local font_ok, font_cfg = pcall(require, "font")
if font_ok and type(font_cfg) == "table" then
	if font_cfg.font then
		config.font = wezterm.font(font_cfg.font)
	end
	if font_cfg.font_size then
		config.font_size = font_cfg.font_size
	end
end

config.keys = {
	{ key = "F11", action = wezterm.action.ToggleFullScreen },
}

return config
