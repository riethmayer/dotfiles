#!/usr/bin/env bash
# Shared brag book library

set -euo pipefail

# Configuration
export BRAG_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/brag-book"

# Get current date and timestamp
brag_date() {
  date +%Y-%m-%d
}

brag_timestamp() {
  date -u +%Y-%m-%dT%H:%M:%S%z
}

# Get git context
brag_git_context() {
  local repo=""
  local branch=""
  local files="[]"
  
  if git rev-parse --git-dir &>/dev/null; then
    repo=$(basename "$(git rev-parse --show-toplevel)")
    branch=$(git branch --show-current 2>/dev/null || echo "")
    files=$(git status --porcelain | awk '{print $2}' | jq -R -s -c 'split("\n") | map(select(length > 0))')
  fi
  
  echo "$repo|$branch|$files"
}

# Ensure brag directory exists
brag_ensure_dir() {
  mkdir -p "$BRAG_DIR"
}

# Write a brag entry to JSONL
# Usage: brag_write_entry "summary" "source" ["extra_json"]
brag_write_entry() {
  local summary="$1"
  local source="${2:-manual}"
  local extra_json="${3:-}"
  
  # Default to empty object if not provided or invalid
  if [[ -z "$extra_json" ]]; then
    extra_json="{}"
  fi
  
  if [[ -z "$summary" ]]; then
    echo "Empty summary, skipping" >&2
    return 1
  fi
  
  brag_ensure_dir
  
  local today=$(brag_date)
  local timestamp=$(brag_timestamp)
  local cwd=$(pwd)
  
  # Parse git context
  IFS='|' read -r repo branch files <<< "$(brag_git_context)"
  
  local jsonl_file="$BRAG_DIR/$today.jsonl"
  
  # Merge base entry with extra JSON
  jq -n \
    --arg ts "$timestamp" \
    --arg sum "$summary" \
    --arg src "$source" \
    --arg cwd "$cwd" \
    --arg repo "$repo" \
    --arg branch "$branch" \
    --argjson files "${files:-[]}" \
    --argjson extra "$extra_json" \
    '$extra + {
      timestamp: $ts, 
      summary: $sum, 
      source: $src, 
      cwd: $cwd, 
      git_repo: $repo, 
      git_branch: $branch, 
      files_changed: $files
    }' >> "$jsonl_file"
  
  echo "Added to $today.jsonl"
}

# List recent brag entries
# Usage: brag_list [days]
brag_list() {
  local days="${1:-7}"
  
  if [[ ! -d "$BRAG_DIR" ]]; then
    echo "No brag entries found" >&2
    return 1
  fi
  
  find "$BRAG_DIR" -name "*.jsonl" -mtime -"$days" | sort -r | while read -r file; do
    echo "=== $(basename "$file" .jsonl) ==="
    jq -r '.timestamp + " | " + .summary + " (" + .source + ")"' "$file" | sort
    echo
  done
}

# Export functions if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  export -f brag_date
  export -f brag_timestamp
  export -f brag_git_context
  export -f brag_ensure_dir
  export -f brag_write_entry
  export -f brag_list
fi