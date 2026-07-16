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

cd "$(dirname "$0")/../../.."

# herdr itself is installed by mise (stow/mise lists herdr = "latest").
if ! command -v herdr &> /dev/null; then
    echo "herdr: not on PATH (run 'mise install' first), skipping" >&2
    exit 0
fi

stow -d stow -t ~ herdr

herdr integration install claude
herdr integration install pi

settings="$HOME/.claude/settings.json"
if [ -f "$settings" ] && command -v jq &> /dev/null; then
    tmp=$(mktemp)
    jq --arg home "$HOME" 'if .hooks.SessionStart then
          .hooks.SessionStart |= (
            map(.hooks |= map(select(
              ((.command | contains($home)) and
               (.command | contains("herdr-agent-state.sh"))) | not
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
