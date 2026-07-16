#!/bin/bash

# Seed pi agent settings from the tracked example, then stow the package.
#
# settings.json is a seam file: pi writes runtime state into it on every
# update (lastChangelogVersion), so the real file is gitignored and only
# settings.json.example is tracked. The seed lands inside the repo dir on
# purpose — the existing ~/.pi/agent/settings.json stow symlink points here.
# Idempotent: never overwrites an existing settings.json.

set -euo pipefail

cd "$(dirname "$0")/../../.."

f="stow/pi/.pi/agent/settings.json"
if [ ! -f "$f" ]; then
    cp "$f.example" "$f"
    echo "pi: seeded settings.json from example"
fi

stow -d stow -t ~ pi
echo "pi setup complete!"
