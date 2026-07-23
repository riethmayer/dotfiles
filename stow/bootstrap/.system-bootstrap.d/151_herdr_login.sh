#!/bin/bash

# Install a launchd agent that starts the herdr server headless at login, so
# after a crash/reboot the session (layout + pane_history screen contents) is
# already restored before Ghostty opens. Attaching later (`herdr session
# attach <name>`) supplies the terminal context that triggers native agent
# resume (claude --resume et al.).
#
# Session comes from HERDR_LOGIN_SESSION (default "eb"; per-machine override
# via 99_local.zsh before running this). Starting while a server already owns
# the socket exits immediately with "already running" — verified harmless, so
# KeepAlive stays false and `herdr server stop` is never fought by launchd.
#
# Same generate-don't-stow rationale as 150_obsidian_today.sh: launchd needs
# absolute paths, which must not be committed.
#
# Idempotent.

set -euo pipefail

LABEL="com.jan.herdr-server"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/herdr-server-login.log"
SESSION="${HERDR_LOGIN_SESSION:-eb}"

HERDR_BIN="$(command -v herdr || true)"
if [ -z "$HERDR_BIN" ]; then
    echo "herdr-login: herdr not on PATH (brew install herdr first), skipping" >&2
    exit 0
fi

if [ "$SESSION" = "default" ]; then
    SOCKET="$HOME/.config/herdr/herdr.sock"
else
    SOCKET="$HOME/.config/herdr/sessions/$SESSION/herdr.sock"
fi

mkdir -p "$HOME/Library/LaunchAgents" "$(dirname "$LOG")" "$(dirname "$SOCKET")"

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${HERDR_BIN}</string>
        <string>server</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>HERDR_SOCKET_PATH</key>
        <string>${SOCKET}</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
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

# bootstrap can fail to load a bad plist without a non-zero exit; verify.
if ! launchctl print "gui/$uid/$LABEL" >/dev/null 2>&1; then
    echo "herdr-login: ERROR - $LABEL did not load after bootstrap" >&2
    exit 1
fi

echo "herdr-login: launchd agent $LABEL installed + verified (session '$SESSION' at login, log: $LOG)"
