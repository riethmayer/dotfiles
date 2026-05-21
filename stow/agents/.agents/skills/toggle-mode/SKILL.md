---
name: toggle-mode
description: Toggle macOS Light/Dark appearance via System Events. Ghostty (configured with `theme = light:Earlybird Light,dark:Earlybird Dark`) and Claude (`theme = "auto"`) follow the system, so one toggle flips terminal + Claude theme in lockstep. Use when the user says "/toggle-mode", "toggle mode", "switch to light/dark", "flip theme", "dark mode", "light mode", or asks to swap appearance. macOS only.
---

# Toggle macOS Light/Dark mode

One command, one toggle. Flips macOS appearance; Ghostty + Claude follow.

## What it does

Runs `toggle-mode` (in `~/bin` via the `scripts` stow package), which invokes:

```applescript
tell application "System Events" to tell appearance preferences
  set dark mode to not dark mode
end tell
```

…then echoes the new state (`light` or `dark`).

## How to invoke

```bash
toggle-mode
```

That's it. No flags, no args. If the user wants an explicit direction instead of a toggle, run osascript directly:

```bash
# Force dark
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
# Force light
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false'
```

## Why this is just a one-liner wrapper

The macOS osascript call is short enough that a skill might feel like overkill — but the skill exists so the user can say "toggle mode" / "dark mode" / "/toggle-mode" in Claude and get the action without naming the script. The skill description is the activation surface; the script is the implementation.

## Requirements

- macOS (osascript + AppleScript System Events).
- `~/bin/toggle-mode` on PATH (from the `scripts` stow package).
- Ghostty config uses `theme = light:<light-theme>,dark:<dark-theme>` so the terminal follows.
- Claude `theme` set to `"auto"` so Claude follows the terminal's detected background.

## Failure modes

- "not authorized to send Apple events to System Events" → user needs to grant the terminal Automation permission for System Events in System Settings → Privacy & Security → Automation.
- No visible change → check Ghostty config still has the `light:...,dark:...` form; a hardcoded theme overrides the toggle.
