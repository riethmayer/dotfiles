#!/usr/bin/env bash
# Toggle Ghostty + tmux themes between Earlybird dark and light.
# Called by the earlybird-theme-toggle pi extension.
#
# Usage: toggle-theme.sh dark|light

set -euo pipefail

MODE="${1:-dark}"

if [ "$MODE" = "light" ]; then
  GHOSTTY_THEME="GitHub Light Default"
  CATPPUCCIN_FLAVOUR="latte"
else
  GHOSTTY_THEME="Dracula"
  CATPPUCCIN_FLAVOUR="mocha"
fi

# ── Ghostty ───────────────────────────────────────────────────────────
GHOSTTY_CFG="$(readlink -f "$HOME/.config/ghostty/config" 2>/dev/null || echo "$HOME/.config/ghostty/config")"

if [ -f "$GHOSTTY_CFG" ]; then
  sed -i '' "s/^theme = .*/theme = ${GHOSTTY_THEME}/" "$GHOSTTY_CFG"
fi

osascript -e '
tell application "System Events"
    tell process "ghostty"
        click menu item "Reload Configuration" of menu "Ghostty" of menu bar 1
    end tell
end tell' 2>/dev/null || true

# ── tmux (catppuccin with Earlybird palette) ──────────────────────────
if command -v tmux &>/dev/null && [ -n "${TMUX:-}" ]; then
  tmux set -g @catppuccin_flavour "$CATPPUCCIN_FLAVOUR"
  PLUGIN="$HOME/.local/share/tmux/plugins/catppuccin-tmux/catppuccin.tmux"
  if [ -x "$PLUGIN" ]; then
    "$PLUGIN"
  fi
fi
