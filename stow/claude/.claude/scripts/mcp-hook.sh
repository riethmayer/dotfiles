#!/usr/bin/env bash
# PostToolUse hook for MCP tools.
# Reads Claude Code hook JSON on stdin, extracts the MCP tool response,
# trims to MAX_LINES / MAX_CHARS, and emits {"systemMessage": "<trimmed>"}
# which Claude Code renders in the TUI.
#
# Configurable via env:
#   MCP_HOOK_MAX_LINES (default 100)
#   MCP_HOOK_MAX_CHARS (default 8000)

set -euo pipefail

MAX_LINES="${MCP_HOOK_MAX_LINES:-100}"
MAX_CHARS="${MCP_HOOK_MAX_CHARS:-8000}"

payload=$(cat)

tool_name=$(jq -r '.tool_name // "unknown"' <<<"$payload")

# Extract output text. Handle common MCP response shapes:
#   string | array-of-content-items | {content: [...]} | {output: "..."} | other
output=$(jq -r '
  def is_array: type == "array";
  def as_text:
    if type == "string" then .
    elif type == "array" then (map(.text // tojson) | join("\n"))
    elif type == "object" and (.content | is_array) then (.content | map(.text // tojson) | join("\n"))
    elif type == "object" and (.text | type) == "string" then .text
    elif type == "object" and (.output | type) == "string" then .output
    else tojson end;
  .tool_response | as_text
' <<<"$payload")

# Pretty-print JSON outputs (object/array only — skip bare strings/numbers/non-JSON).
if pretty=$(jq -e 'if type == "object" or type == "array" then . else empty end' <<<"$output" 2>/dev/null); then
  output="$pretty"
fi

total_lines=$(printf '%s\n' "$output" | wc -l | tr -d ' ')
total_chars=${#output}

trimmed=$(printf '%s' "$output" | awk -v n="$MAX_LINES" 'NR<=n')
if (( ${#trimmed} > MAX_CHARS )); then
  trimmed=${trimmed:0:$MAX_CHARS}
fi

suffix=""
if (( total_lines > MAX_LINES )) || (( total_chars > MAX_CHARS )); then
  suffix=$'\n… [truncated: '"$total_lines"' lines / '"$total_chars"' chars total — run ~/.claude/scripts/mcp-view.sh --last 1 for full output]'
fi

msg="── $tool_name ──"$'\n'"$trimmed$suffix"

jq -cn --arg m "$msg" '{systemMessage: $m}'
