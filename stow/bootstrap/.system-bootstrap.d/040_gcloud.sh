#!/usr/bin/env bash
# Install/update Google Cloud SDK

set -euo pipefail

GCLOUD_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/google-cloud-sdk"

echo "==> Setting up Google Cloud SDK"

# Install if not present
if [[ ! -d "$GCLOUD_HOME" ]]; then
  echo "Installing Google Cloud SDK..."
  curl https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir="$(dirname "$GCLOUD_HOME")"
else
  echo "Google Cloud SDK already installed"
fi

# Update to latest version
if [[ -x "$GCLOUD_HOME/bin/gcloud" ]]; then
  echo "Updating components..."
  "$GCLOUD_HOME/bin/gcloud" components update --quiet
fi

echo "✓ Google Cloud SDK setup complete"
