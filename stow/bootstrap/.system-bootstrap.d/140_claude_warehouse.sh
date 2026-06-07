#!/bin/bash

# Install a launchd agent that keeps the claude-warehouse DuckDB fresh.
#
# claude-warehouse (enabled via enabledPlugins in stow/claude/.claude/settings.json)
# syncs every ~/.claude/projects session into ~/.claude/claude.duckdb and embeds
# it for /claude-warehouse:recall. Its own SessionStart hook only launches the
# dashboard, not the sync, so without this agent the DB goes stale between manual
# runs. This agent runs claude-warehouse-sync (sync + embed, one process) every
# 10 minutes and at login.
#
# The actual work lives in the stowed ~/bin/claude-warehouse-sync script (single
# process so sync and embed never contend for DuckDB's single writer lock); this
# generator just wires it to launchd.
#
# Why generate the plist here instead of stowing one:
#   - launchd plist values need ABSOLUTE paths; committing /Users/<me>/... would
#     break on a machine with a different $HOME.
#   - Your other LaunchAgents are real files too (com.jan.granola-to-obsidian),
#     not stow symlinks, so match that. The generator is tracked + portable; the
#     realized plist is machine-local (lives under ~/Library, outside the repo).
#
# Idempotent. No-ops harmlessly until the plugin is installed (the wrapper guards
# for that), so it is safe to run on a fresh machine during bootstrap.

set -euo pipefail

LABEL="com.claude-warehouse.sync"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/claude-warehouse-sync.log"
WRAPPER="$HOME/bin/claude-warehouse-sync"

if [ ! -x "$WRAPPER" ]; then
    echo "claude-warehouse: $WRAPPER missing (run 'mise run install' first), skipping" >&2
    exit 0
fi

# Pre-flight: assert the wrapper can resolve its dependencies (uv + plugin)
# BEFORE wiring it to launchd. Otherwise the agent would silently no-op every
# 10 min - the exact stale-warehouse failure this setup exists to prevent. A
# not-yet-cached plugin is fine (--check exits 0); a missing uv is fatal.
if ! "$WRAPPER" --check; then
    echo "claude-warehouse: wrapper self-check failed (see above) - not installing the agent" >&2
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

# Assert the agent actually registered; bootstrap can fail to load a bad plist
# without a non-zero exit, so verify rather than trust.
if ! launchctl print "gui/$uid/$LABEL" >/dev/null 2>&1; then
    echo "claude-warehouse: ERROR - $LABEL did not load after bootstrap" >&2
    exit 1
fi

echo "claude-warehouse: launchd agent $LABEL installed + verified loaded (sync + embed every 600s, log: $LOG)"
