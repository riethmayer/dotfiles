#!/bin/bash

# claude_desktop_reset.sh — Daily reset for the Claude Desktop app (macOS)
#
# ───────────────────────────────────────────────────────────────────────
# WHAT LIVES ONLINE (Anthropic servers) — NOT touched by this script:
#   • Conversations / chat history          (sync from claude.ai account)
#   • Projects (instructions + knowledge)   (server-side)
#   • Memory feature                        (manage at claude.ai/settings)
#   • Custom instructions / preferences     (account-scoped)
#   • File uploads                          (server-side blobs)
#   • Cowork threads / agent runs           (run on Anthropic infra)
#   • Subscription / billing
#
# To wipe ONLINE state, use claude.ai → Settings, not this script.
# ───────────────────────────────────────────────────────────────────────
# WHAT LIVES LOCALLY and IS cleared:
#   • Electron caches (WebKit, GPU, shader, code) — safe, auto-rebuilt
#   • Crash dumps + Sentry telemetry
#   • Logs (~/Library/Logs/Claude/*)
#   • --full only: cookies + Local/Session Storage + IndexedDB → signs you out
#
# WHAT IS PRESERVED (never deleted):
#   • claude_desktop_config.json            ← your MCP server configs
#   • config.json                           ← app settings
#   • cowork-enabled-cli-ops.json           ← Cowork toggle
#   • git-worktrees.json                    ← worktree registry
#   • local-agent-mode-sessions/            ← active agent sessions
#   • vm_bundles/ + claude-code-vm/         ← Cowork/CC VM bundles (large)
#   • ant-did                               ← anonymous device ID
#   • com.anthropic.claudefordesktop.plist  ← UI prefs
# ───────────────────────────────────────────────────────────────────────

set -e

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

MODE="cache"
for arg in "$@"; do
  case "$arg" in
    --full) MODE="full" ;;
    --help|-h)
      cat <<EOF
Usage: $0 [--full]

  (default)  Clear caches + logs only. Safe — does NOT log you out,
             does NOT touch MCP config, does NOT touch Cowork bundles.
  --full     Also clear cookies + storage. WILL sign you out on next launch.

Note: conversations, projects, and memory live on Anthropic's servers.
Manage those at https://claude.ai/settings — this script can't touch them.
EOF
      exit 0
      ;;
  esac
done

echo -e "${YELLOW}Claude Desktop Reset (${MODE})${NC}"
echo "================================"

# Refuse to run while the app is open — clearing live state corrupts the DBs
if pgrep -x "Claude" >/dev/null 2>&1; then
  echo -e "${RED}Claude desktop app is running. Quit it first (⌘Q), then re-run.${NC}"
  exit 1
fi

APP_SUPPORT="$HOME/Library/Application Support/Claude"
CACHES_APP="$HOME/Library/Caches/com.anthropic.claudefordesktop"
CACHES_SHIPIT="$HOME/Library/Caches/com.anthropic.claudefordesktop.ShipIt"
LOGS="$HOME/Library/Logs/Claude"

if [ ! -d "$APP_SUPPORT" ]; then
  echo -e "${RED}Claude desktop app not installed (no $APP_SUPPORT).${NC}"
  exit 0
fi

clear_dir () {
  local label="$1"
  local path="$2"
  if [ -d "$path" ]; then
    rm -rf "$path"
    echo -e "${GREEN}✓ Cleared $label${NC}"
  fi
}

clear_file () {
  local label="$1"
  local path="$2"
  if [ -f "$path" ]; then
    rm -f "$path"
    echo -e "${GREEN}✓ Cleared $label${NC}"
  fi
}

# --- Electron caches (always safe; rebuilt on next launch) ---
clear_dir "WebKit cache"        "$APP_SUPPORT/Cache"
clear_dir "Code cache"          "$APP_SUPPORT/Code Cache"
clear_dir "GPU cache"           "$APP_SUPPORT/GPUCache"
clear_dir "DawnGraphite cache"  "$APP_SUPPORT/DawnGraphiteCache"
clear_dir "DawnWebGPU cache"    "$APP_SUPPORT/DawnWebGPUCache"
clear_dir "Shader cache"        "$APP_SUPPORT/ShaderCache"
clear_dir "Blob storage"        "$APP_SUPPORT/blob_storage"
clear_file "fcache file"        "$APP_SUPPORT/fcache"

# --- Crash dumps + telemetry ---
clear_dir "Crashpad dumps"      "$APP_SUPPORT/Crashpad"
clear_dir "Sentry telemetry"    "$APP_SUPPORT/sentry"

# --- User Library caches (incl. auto-updater scratch) ---
clear_dir "App cache (Library)"     "$CACHES_APP"
clear_dir "ShipIt cache (updater)"  "$CACHES_SHIPIT"

# --- Logs ---
clear_dir "App-support logs"  "$APP_SUPPORT/logs"
clear_dir "User Library logs" "$LOGS"

# --- Full mode: session state (logs you out) ---
if [ "$MODE" = "full" ]; then
  clear_dir  "Local Storage"     "$APP_SUPPORT/Local Storage"
  clear_dir  "Session Storage"   "$APP_SUPPORT/Session Storage"
  clear_dir  "IndexedDB"         "$APP_SUPPORT/IndexedDB"
  clear_dir  "WebStorage"        "$APP_SUPPORT/WebStorage"
  clear_dir  "Shared Dictionary" "$APP_SUPPORT/Shared Dictionary"
  clear_dir  "Partitions"        "$APP_SUPPORT/Partitions"
  clear_file "Cookies"           "$APP_SUPPORT/Cookies"
  clear_file "Cookies-journal"   "$APP_SUPPORT/Cookies-journal"
  clear_file "TransportSecurity" "$APP_SUPPORT/TransportSecurity"
  clear_file "Trust Tokens"      "$APP_SUPPORT/Trust Tokens"
  clear_file "Trust Tokens-journal" "$APP_SUPPORT/Trust Tokens-journal"
  clear_file "SharedStorage"     "$APP_SUPPORT/SharedStorage"
  clear_file "SharedStorage-wal" "$APP_SUPPORT/SharedStorage-wal"
  clear_file "DIPS"              "$APP_SUPPORT/DIPS"
  clear_file "DIPS-wal"          "$APP_SUPPORT/DIPS-wal"
  clear_file "buddy-tokens"      "$APP_SUPPORT/buddy-tokens.json"
  echo -e "${YELLOW}⚠  You will be signed out on next launch.${NC}"
fi

# --- Confirm preserved files (sanity check) ---
echo ""
echo "Preserved:"
for f in claude_desktop_config.json config.json cowork-enabled-cli-ops.json git-worktrees.json ant-did; do
  [ -f "$APP_SUPPORT/$f" ] && echo "  ✓ $f"
done
for d in local-agent-mode-sessions vm_bundles claude-code claude-code-vm; do
  [ -d "$APP_SUPPORT/$d" ] && echo "  ✓ $d/"
done
[ -f "$HOME/Library/Preferences/com.anthropic.claudefordesktop.plist" ] && \
  echo "  ✓ com.anthropic.claudefordesktop.plist"

echo ""
echo -e "${GREEN}Done.${NC}"
echo -e "Reminder: chats + memory live on Anthropic's servers — manage them"
echo -e "at https://claude.ai/settings, this script can't reach them."
