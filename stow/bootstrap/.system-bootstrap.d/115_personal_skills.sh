#!/bin/bash

# Install/update Jan's personal skills repo and keep it fresh in the background.
# The repo feeds both Claude (via the enabled jan-* marketplace plugins) and Codex
# (~/.agents/skills plus the local jan-skills marketplace).

set -euo pipefail

LABEL="com.jan.personal-skills.sync"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/personal-skills-sync.log"
WRAPPER="$HOME/bin/personal-skills-sync"

if [ ! -x "$WRAPPER" ]; then
    echo "personal-skills: $WRAPPER missing (run 'mise run install' first), skipping" >&2
    exit 0
fi

"$WRAPPER"

if ! command -v launchctl >/dev/null 2>&1; then
    echo "personal-skills: launchctl missing; skipping background updater"
    exit 0
fi

mkdir -p "$HOME/Library/LaunchAgents" "$(dirname "$LOG")"

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${WRAPPER}</string>
        <string>--git-only</string>
    </array>
    <key>StartInterval</key>
    <integer>3600</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>ProcessType</key>
    <string>Background</string>
    <key>StandardOutPath</key>
    <string>${LOG}</string>
    <key>StandardErrorPath</key>
    <string>${LOG}</string>
</dict>
</plist>
PLIST

uid="$(id -u)"
launchctl bootout "gui/$uid/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$uid" "$PLIST"

if ! launchctl print "gui/$uid/$LABEL" >/dev/null 2>&1; then
    echo "personal-skills: ERROR - $LABEL did not load after bootstrap" >&2
    exit 1
fi

echo "personal-skills: launchd agent $LABEL installed + verified loaded (sync every 3600s, log: $LOG)"
