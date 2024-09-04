local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Dracula (Official)"
config.font = wezterm.font("GeistMono Nerd Font Propo")
-- =>
config.font_size = 20.0
return config
