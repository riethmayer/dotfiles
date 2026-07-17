#!/bin/bash

# Seed pi agent settings from the tracked example, then stow the package.
#
# settings.json is a seam file: pi writes runtime state into it on every
# update (lastChangelogVersion), so the real file is gitignored and only
# settings.json.example is tracked. The seed lands inside the repo dir on
# purpose — the ~/.pi/agent/settings.json stow symlink points here.
# Idempotent: never overwrites an existing settings.json.

set -euo pipefail

# Resolve the repo root physically: $0 may be the stowed
# ~/.system-bootstrap.d/<script> path, where a logical ../../.. walks out of
# $HOME instead of into the repo.
cd "$(cd "$(dirname "$0")" && pwd -P)/../../.."

f="stow/pi/.pi/agent/settings.json"
live="$HOME/.pi/agent/settings.json"

# If pi replaced a dangling seam symlink with a real file (e.g. after a pull
# that renamed the tracked file), adopt it as this machine's seam content so
# the stow below can relink instead of conflicting.
if [ -f "$live" ] && [ ! -L "$live" ] && [ ! -f "$f" ]; then
    mv "$live" "$f"
    echo "pi: adopted existing live settings.json into the seam"
fi

if [ ! -f "$f" ]; then
    cp "$f.example" "$f"
    echo "pi: seeded settings.json from example"
fi

stow -d stow -t ~ pi
echo "pi setup complete!"
