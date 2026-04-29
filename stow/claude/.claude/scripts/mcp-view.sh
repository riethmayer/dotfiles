#!/usr/bin/env bash
# mcp-view.sh — print MCP tool_use/tool_result pairs from a Claude Code session JSONL.
#
# Usage:
#   mcp-view.sh                      # newest session for current $PWD project
#   mcp-view.sh <session-uuid>       # specific session in current project
#   mcp-view.sh <path-to.jsonl>      # any JSONL file
#   mcp-view.sh --last [N]           # only the last N MCP pairs (default 1)
#   mcp-view.sh --follow             # tail newest session, print MCP pairs as they land
#   mcp-view.sh --list               # list sessions for current project
#
# Output: one block per MCP call:
#   ── <tool name> ──
#   input:  <compact JSON>
#   output: <result text>
#
# Requires: jq.

set -euo pipefail

projects_dir="$HOME/.claude/projects"
slug=$(pwd | sed 's|/|-|g')
proj_dir="$projects_dir/$slug"

die() { echo "mcp-view: $*" >&2; exit 1; }

newest_session() {
  [[ -d "$proj_dir" ]] || die "no project dir: $proj_dir"
  # shellcheck disable=SC2012
  local f
  f=$(ls -t "$proj_dir"/*.jsonl 2>/dev/null | awk 'NR==1')
  [[ -n "$f" ]] || die "no sessions in $proj_dir"
  printf '%s\n' "$f"
}

resolve_file() {
  local arg="${1:-}"
  if [[ -z "$arg" ]]; then
    newest_session
  elif [[ -f "$arg" ]]; then
    printf '%s\n' "$arg"
  else
    local candidate="$proj_dir/$arg.jsonl"
    [[ -f "$candidate" ]] || die "no such session: $arg (looked at $candidate)"
    printf '%s\n' "$candidate"
  fi
}

render_pairs() {
  local last="${1:-0}"
  jq -r -s --argjson last "$last" '
    def is_array: type == "array";
    def safe_array(x): (x // []) | if is_array then . else [] end;

    ([
      .[]
      | select(.type == "assistant")
      | safe_array(.message.content)[]
      | select(.type == "tool_use" and ((.name // "") | startswith("mcp__")))
      | {(.id): {name: .name, input: .input}}
    ] | add // {}) as $uses
    |
    [
      .[]
      | select(.type == "user")
      | safe_array(.message.content)[]
      | select(.type == "tool_result")
      | . as $r
      | ($uses[$r.tool_use_id] // null) as $u
      | select($u != null)
      | {
          name: $u.name,
          input: ($u.input | tojson),
          output: (
            if ($r.content | type) == "string" then $r.content
            elif ($r.content | type) == "array" then
              ($r.content | map(.text // (. | tojson)) | join("\n"))
            else ($r.content | tojson) end
          )
        }
    ]
    | (if $last > 0 then .[-$last:] else . end)
    | .[]
    | "── \(.name) ──\ninput:  \(.input)\noutput: \(.output)\n"
  '
}

case "${1:-}" in
  --list)
    [[ -d "$proj_dir" ]] || die "no project dir: $proj_dir"
    ls -lt "$proj_dir"/*.jsonl
    ;;
  --last)
    n="${2:-1}"
    [[ "$n" =~ ^[0-9]+$ ]] || die "--last expects a non-negative integer, got: $n"
    file=$(newest_session)
    echo "session: $file (last $n)" >&2
    render_pairs "$n" < "$file"
    ;;
  --follow|-f)
    file=$(newest_session)
    echo "following: $file" >&2
    # Re-slurp the whole file on every append — small cost, exact parsing.
    prev_size=0
    while :; do
      size=$(wc -c < "$file")
      if [[ "$size" -ne "$prev_size" ]]; then
        clear
        render_pairs 0 < "$file" || true
        prev_size=$size
      fi
      sleep 1
    done
    ;;
  ""|*)
    file=$(resolve_file "${1:-}")
    echo "session: $file" >&2
    render_pairs 0 < "$file"
    ;;
esac
