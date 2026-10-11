#!/bin/bash

# Install a launchd agent that runs herdr-theme-sync whenever macOS flips
# Light/Dark, so Claude Code and Pi panes re-theme without /toggle-mode.
#
# Ghostty and herdr chrome follow the system appearance on their own, but the
# color-scheme report does not reliably reach pane PTYs (see
# ~/bin/herdr-theme-sync). Any switch outside /toggle-mode (Control Center,
# the Auto schedule) can leave theme-aware agents on their startup appearance.
#
# The watcher is a tiny Swift program listening for the distributed
# AppleInterfaceThemeChangedNotification: event-driven, no polling. Its source
# is inlined here and compiled to ~/.local/bin, because every file in
# .system-bootstrap.d is executed by the bootstrap runner.
#
# Idempotent.

set -euo pipefail

LABEL="com.jan.appearance-watch"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/appearance-watch.log"
BIN="$HOME/.local/bin/appearance-watch"
SYNC="$HOME/bin/herdr-theme-sync"

if [ ! -x "$SYNC" ]; then
    echo "appearance-watch: $SYNC missing (run 'mise run install' first), skipping" >&2
    exit 0
fi
if ! command -v swiftc >/dev/null 2>&1; then
    echo "appearance-watch: swiftc not found (xcode-select --install), skipping" >&2
    exit 0
fi

mkdir -p "$(dirname "$BIN")" "$HOME/Library/LaunchAgents" "$(dirname "$LOG")"

src="$(mktemp -d)/appearance-watch.swift"
cat > "$src" <<'SWIFT'
import Foundation

// argv[1] is the command to run on every Light/Dark switch.
let command = CommandLine.arguments.dropFirst().first ?? "herdr-theme-sync"

func sync() {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: command)
    do { try p.run(); p.waitUntilExit() } catch { FileHandle.standardError.write("appearance-watch: \(error)\n".data(using: .utf8)!) }
}

DistributedNotificationCenter.default().addObserver(
    forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
    object: nil, queue: .main
) { _ in
    // The notification can arrive before AppleInterfaceStyle is readable.
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { sync() }
}
RunLoop.main.run()
SWIFT
swiftc -O -o "$BIN" "$src"
rm -rf "$(dirname "$src")"

# launchd starts with a bare PATH; herdr-theme-sync needs herdr and jq.
path="/usr/bin:/bin:/usr/sbin:/sbin"
for tool in jq herdr; do
    d="$(dirname "$(command -v "$tool" 2>/dev/null || echo /usr/bin/x)")"
    case ":$path:" in *":$d:"*) ;; *) path="$d:$path" ;; esac
done

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${BIN}</string>
        <string>${SYNC}</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>${path}</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <!-- Background jobs get a "speculative" spawn that launchd may defer
         indefinitely; Adaptive starts now and still idles at low priority. -->
    <key>ProcessType</key>
    <string>Adaptive</string>
    <key>StandardOutPath</key>
    <string>${LOG}</string>
    <key>StandardErrorPath</key>
    <string>${LOG}</string>
</dict>
</plist>
PLIST

uid="$(id -u)"
launchctl bootout "gui/$uid/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$uid" "$PLIST"
launchctl kickstart "gui/$uid/$LABEL"

if ! launchctl print "gui/$uid/$LABEL" >/dev/null 2>&1; then
    echo "appearance-watch: ERROR - $LABEL did not load after bootstrap" >&2
    exit 1
fi

echo "appearance-watch: launchd agent $LABEL installed + verified loaded (log: $LOG)"
