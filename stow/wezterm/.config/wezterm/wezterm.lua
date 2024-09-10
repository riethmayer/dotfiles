local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Dracula (Official)"
-- config.font = wezterm.font("GeistMono Nerd Font Propo")
config.font = wezterm.font("Hack Nerd Font Mono")
-- =>
config.font_size = 24.0
return config
