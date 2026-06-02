#!/bin/bash

# Install a launchd agent that keeps the claude-warehouse DuckDB fresh.
#
# claude-warehouse (enabled via enabledPlugins in stow/claude/.claude/settings.json)
# syncs every ~/.claude/projects session into ~/.claude/claude.duckdb. Its own
# SessionStart hook only launches the dashboard, not the sync, so without this
# agent the DB goes stale between manual runs. This agent runs sync.py every 10
# minutes (and at login).
#
# Why generate the plist here instead of stowing one:
#   - launchd plist values (StandardOutPath, the command) need ABSOLUTE paths;
#     committing /Users/<me>/... would break on a machine with a different $HOME.
#   - Your other LaunchAgents are real files too (com.jan.granola-to-obsidian),
#     not stow symlinks, so match that. The generator is tracked + portable; the
#     realized plist is machine-local (gitignored by living under ~/Library).
#
# Defensive: the command resolves the plugin version by glob at run time and
# no-ops if the plugin is not installed yet (fresh machine, before Claude's first
# launch auto-installs it from the committed enabledPlugins). Idempotent.

set -euo pipefail

LABEL="com.claude-warehouse.sync"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/claude-warehouse-sync.log"
PLUGIN_BASE="$HOME/.claude/plugins/cache/sderosiaux-claude-plugins/claude-warehouse"
UV="$HOME/.local/bin/uv"

# uv is the only external dep (sync.py is a PEP-723 self-contained script).
if [ ! -x "$UV" ]; then
    echo "claude-warehouse: uv not found at $UV, skipping launchd agent" >&2
    exit 0
fi

# Command run on each interval. $s / the glob stay literal so they evaluate at
# run time (version-proof across plugin updates); the no-op guard handles a
# not-yet-installed plugin. timeout caps a runaway sync.
CMD='PATH=/opt/homebrew/bin:/usr/bin:/bin; s=$(ls "'"$PLUGIN_BASE"'"/*/scripts/sync.py 2>/dev/null | sort | tail -1); [ -n "$s" ] || exit 0; exec timeout 240 "'"$UV"'" run --quiet --script "$s"'

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
        <string>/bin/sh</string>
        <string>-c</string>
        <string>${CMD}</string>
    </array>
    <key>StartInterval</key>
    <integer>600</integer>
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

echo "claude-warehouse: launchd agent $LABEL installed (sync every 600s, log: $LOG)"
