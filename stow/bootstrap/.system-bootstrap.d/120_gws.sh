#!/bin/bash

# Install the Google Workspace CLI (gws) — googleworkspace/cli.
# Used by the gws-* agent skills (gmail, calendar, drive, sheets, docs, meet).
# Not an officially supported Google product. Pinned + checksum-verified.

set -euo pipefail

GWS_VERSION="0.22.5"
INSTALL_DIR="$HOME/.local/bin"
BIN="$INSTALL_DIR/gws"

# Idempotent: skip if the pinned version is already installed.
if [ -x "$BIN" ] && "$BIN" --version 2>/dev/null | grep -q "gws $GWS_VERSION"; then
    echo "gws $GWS_VERSION already installed"
    exit 0
fi

# Map uname -> the release's Rust target triple.
os="$(uname -s)"
arch="$(uname -m)"
case "$arch" in
    arm64 | aarch64) arch="aarch64" ;;
    x86_64 | amd64) arch="x86_64" ;;
    *) echo "gws: unsupported arch '$arch'" >&2; exit 1 ;;
esac
case "$os" in
    Darwin) target="${arch}-apple-darwin" ;;
    Linux) target="${arch}-unknown-linux-gnu" ;;
    *) echo "gws: unsupported OS '$os'" >&2; exit 1 ;;
esac

echo "Installing gws $GWS_VERSION ($target)..."

base="https://github.com/googleworkspace/cli/releases/download/v${GWS_VERSION}"
archive="google-workspace-cli-${target}.tar.gz"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

curl -fsSLO "$base/$archive"
curl -fsSLO "$base/$archive.sha256"

# Verify checksum (macOS: shasum; Linux: sha256sum). Format is compatible.
if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 -c "$archive.sha256"
else
    sha256sum -c "$archive.sha256"
fi

tar -xzf "$archive"
mkdir -p "$INSTALL_DIR"
chmod +x gws
mv gws "$BIN"

echo "gws installed to $BIN"
"$BIN" --version 2>/dev/null | head -1
echo "Run 'gws auth login' to authenticate."
