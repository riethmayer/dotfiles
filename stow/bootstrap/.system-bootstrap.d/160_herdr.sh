#!/bin/bash

# Herdr terminal workspace manager: stow config + install agent integrations.
#
# `herdr integration install <tool>` writes a version-stamped shim into the
# tool's config dir (claude: hooks/herdr-agent-state.sh, pi:
# extensions/herdr-agent-state.ts). Those dirs are stowed into this repo, so
# the shims are TRACKED — they contain no machine paths, only HERDR_* env
# lookups. Reinstalling is how herdr ships integration updates: rerun this
# after `herdr update` and commit the diff if the shims changed.
#
# The claude installer also appends a SessionStart hook entry to
# ~/.claude/settings.json with an ABSOLUTE home path, which must never be
# committed (repo is shared across machines with different $HOME). The
# tracked settings.json already carries an equivalent guarded $HOME entry,
# and the installer's exact-string matching doesn't recognize it, so strip
# the absolute duplicate after every install. Idempotent.

set -euo pipefail

# Resolve the repo root physically: $0 may be the stowed
# ~/.system-bootstrap.d/<script> path, where a logical ../../.. walks out of
# $HOME instead of into the repo.
cd "$(cd "$(dirname "$0")" && pwd -P)/../../.."

# herdr itself is installed by mise (stow/mise lists herdr = "latest").
if ! command -v herdr &> /dev/null; then
    echo "herdr: not on PATH (run 'mise install' first), skipping" >&2
    exit 0
fi

# jq is required to strip the absolute-path hook entry the installer writes
# into the tracked settings.json; without it we'd leave the violation behind.
if ! command -v jq &> /dev/null; then
    echo "herdr: jq is required (brew install jq), refusing to run the installer without it" >&2
    exit 1
fi

# A machine that ran herdr before stowing dotfiles has REAL shim files where
# the repo tracks them; they'd conflict with every later stow run. They are
# machine-independent and regenerated below, so drop them. ([ ! -L dir ]
# means the parent dir is not yet a stow symlink into the repo.)
claude_shim="$HOME/.claude/hooks/herdr-agent-state.sh"
pi_shim="$HOME/.pi/agent/extensions/herdr-agent-state.ts"
for shim in "$claude_shim" "$pi_shim"; do
    dir="$(dirname "$shim")"
    if [ -f "$shim" ] && [ ! -L "$shim" ] && [ ! -L "$dir" ]; then
        rm -f "$shim"
        echo "herdr: removed pre-stow shim $shim (tracked copy takes over)"
    fi
done

# Avoid stow folding ~/.config/herdr into a repo-pointing dir symlink —
# herdr writes runtime state (logs, sockets, session.json) next to config.toml.
mkdir -p "$HOME/.config/herdr"
stow -d stow -t ~ herdr

# The integrations must write through the stowed symlinks into the repo;
# otherwise they'd create real files that conflict with the tracked shims.
for dir in "$(dirname "$claude_shim")" "$(dirname "$pi_shim")"; do
    if [ ! -L "$dir" ]; then
        echo "herdr: $dir is not a stow symlink yet (run 'mise run install' first), skipping integrations" >&2
        exit 0
    fi
done

herdr integration install claude
herdr integration install pi

settings="$HOME/.claude/settings.json"
if [ -f "$settings" ]; then
    tmp=$(mktemp)
    jq --arg home "$HOME" 'if .hooks.SessionStart then
          .hooks.SessionStart |= (
            map(.hooks |= map(select(
              (((.command // "") | contains($home)) and
               ((.command // "") | contains("herdr-agent-state.sh"))) | not
            )))
            | map(select((.hooks | length) > 0))
          )
        else . end' "$settings" > "$tmp"
    # cat (not mv): the file is a stow symlink into the repo — write through it.
    cat "$tmp" > "$settings"
    rm -f "$tmp"
fi

herdr integration status
echo "herdr setup complete!"
