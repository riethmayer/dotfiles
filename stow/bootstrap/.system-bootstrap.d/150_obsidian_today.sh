#!/bin/bash

# Install a launchd agent that keeps a Desktop alias pointing at today's
# Obsidian journal folder.
#
# The actual work lives in the stowed ~/bin/obsidian-today script (creates the
# per-date journal folder if missing, drops a Finder alias on the Desktop,
# removes previous days' aliases); this generator just wires it to launchd:
# daily shortly after midnight plus at login/load, so a Mac that was asleep at
# midnight catches up on wake.
#
# Why generate the plist here instead of stowing one:
#   - launchd plist values need ABSOLUTE paths; committing /Users/<me>/... would
#     break on a machine with a different $HOME.
#   - launchd does not source zsh config, so OBSIDIAN_VAULT_DAILY_JOURNAL is
#     baked into the plist at generation time (inherited from the calling shell,
#     with the tracked zsh default as fallback).
#
# Idempotent.

set -euo pipefail

LABEL="com.jan.obsidian-today"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/obsidian-today.log"
WRAPPER="$HOME/bin/obsidian-today"
JOURNAL="${OBSIDIAN_VAULT_DAILY_JOURNAL:-$HOME/obsidian/riethmayer/2 - Areas/Journal}"

if [ ! -x "$WRAPPER" ]; then
    echo "obsidian-today: $WRAPPER missing (run 'mise run install' first), skipping" >&2
    exit 0
fi

if [ ! -d "$JOURNAL" ]; then
    echo "obsidian-today: journal dir not found at $JOURNAL - not installing the agent" >&2
    exit 1
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
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>OBSIDIAN_VAULT_DAILY_JOURNAL</key>
        <string>${JOURNAL}</string>
    </dict>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>0</integer>
        <key>Minute</key>
        <integer>5</integer>
    </dict>
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

# (Re)load idempotently: bootout an existing instance, then bootstrap fresh.
uid="$(id -u)"
launchctl bootout "gui/$uid/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$uid" "$PLIST"

# Assert the agent actually registered; bootstrap can fail to load a bad plist
# without a non-zero exit, so verify rather than trust.
if ! launchctl print "gui/$uid/$LABEL" >/dev/null 2>&1; then
    echo "obsidian-today: ERROR - $LABEL did not load after bootstrap" >&2
    exit 1
fi

echo "obsidian-today: launchd agent $LABEL installed + verified loaded (daily 00:05 + at login, log: $LOG)"
