#!/bin/bash

# Exit on error
set -e

# Install claude if not present
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

# Stow claude configuration. Resolve the repo root physically: $0 may be the
# stowed ~/.system-bootstrap.d/<script> path, where a logical ../../.. walks
# out of $HOME instead of into the repo.
cd "$(cd "$(dirname "$0")" && pwd -P)/../../.."
stow -d stow -t ~ claude

# The ~/.claude/skills symlink is retired (personal skills load via the
# enabled jan-* marketplace plugins); drop a dangling leftover from the
# pre-plugin layout.
if [ -L "$HOME/.claude/skills" ] && [ ! -e "$HOME/.claude/skills" ]; then
    rm "$HOME/.claude/skills"
fi

# Repair stale plugin runtime state. installed_plugins.json caches absolute
# installPaths; this repo is shared across machines with different $HOME values,
# so a path baked on one laptop (e.g. /Users/jan/...) dangles on another
# (/Users/janriethmayer/...) and Claude fails to load plugins. enabledPlugins in
# settings.json is the source of truth — Claude re-resolves runtime state on
# launch — so resetting the cache when any installPath is missing is safe.
# Idempotent: a healthy (or already-empty) install is a no-op.
plugins_dir="$HOME/.claude/plugins"
installed="$plugins_dir/installed_plugins.json"
if [ -f "$installed" ]; then
    stale=0
    if command -v jq &> /dev/null; then
        while IFS= read -r path; do
            if [ -n "$path" ] && [ ! -e "$path" ]; then stale=1; break; fi
        done < <(jq -r '.plugins // {} | to_entries[] | .value[]?.installPath // empty' "$installed")
    elif grep -q '"installPath"' "$installed" && grep '"installPath"' "$installed" | grep -vq "$HOME"; then
        # No jq: flag any installPath that isn't under the current $HOME.
        stale=1
    fi
    if [ "$stale" -eq 1 ]; then
        echo "Repairing stale Claude plugin runtime state..."
        printf '{\n  "version": 2,\n  "plugins": {}\n}\n' > "$installed"
        rm -f "$plugins_dir/known_marketplaces.json"
        [ -d "$plugins_dir/cache" ] && rm -rf "${plugins_dir:?}/cache"/* 2>/dev/null || true
        echo "  Reset runtime state; Claude will re-resolve from enabledPlugins on next launch."
    fi
fi

# Seed Claude Desktop config. It is deliberately NOT stowed (the app rewrites it
# at runtime — device name, account UUID, epitaxyPrefs; see
# stow/agents/.stow-local-ignore), so copy the committed seed only when absent.
# This never clobbers an existing live config.
desktop_config_dir="$HOME/Library/Application Support/Claude"
desktop_config="$desktop_config_dir/claude_desktop_config.json"
desktop_seed="stow/agents/Library/Application Support/Claude/claude_desktop_config.json"
if [ ! -e "$desktop_config" ]; then
    echo "Seeding Claude Desktop config..."
    mkdir -p "$desktop_config_dir"
    cp "$desktop_seed" "$desktop_config"
fi

echo "Claude Code setup complete!"
