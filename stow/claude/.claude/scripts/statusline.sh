#!/bin/bash
# Claude Code status line. Reads the statusline JSON from stdin and renders:
#   <model> | <dir> | ctx:<pct> <used>/<size> | 5h:<pct> | 7d:<pct>
#
# ctx is color-coded against the "dumb zone" (context rot: model quality
# measurably degrades long before the window is full; HumanLayer's guidance
# is to stay under ~40% utilization):
#   green  < 40%   comfortable
#   orange 40-69%  degradation territory — finish up, or /compact deliberately
#   red    >= 70%  dumb zone — hand off (/whats-next) instead of starting new work
# Rate limits (5h/7d) color at 60/85 — they measure quota, not quality.
#
# Everything comes from the statusline stdin JSON (statusline.md):
#   .context_window.used_percentage   input-side %, pre-calculated
#   .rate_limits.{five_hour,seven_day}.used_percentage
#     Pro/Max only and absent until the first API response — shown as a
#     green 0% then. Replaced the old usage-cache.sh keychain+endpoint fetch,
#     which silently broke and is retired.
# Under herdr, reports ctx tokens as pane metadata for the sidebar.

input=$(cat)

j() { jq -r "$1" <<<"$input"; }

model=$(j '.model.display_name // empty')
dir=$(basename "$(j '.workspace.current_dir // empty')")

ctx_pct=$(j '.context_window.used_percentage // empty | round')
ctx_used=$(j '.context_window.total_input_tokens // empty')
ctx_size=$(j '.context_window.context_window_size // empty')
h5=$(j '.rate_limits.five_hour.used_percentage // empty | round')
d7=$(j '.rate_limits.seven_day.used_percentage // empty | round')

G=$'\033[32m'; O=$'\033[33m'; R=$'\033[31m'; X=$'\033[0m'

paint() { # $1=rounded pct or empty, $2=orange threshold, $3=red threshold
  # Empty (pre-first-response) renders as green 0% — real numbers arrive
  # from the same payload one turn later, so a brief 0 can't lie for long.
  local v=${1:-0}
  local c=$G
  [ "$v" -ge "$2" ] && c=$O
  [ "$v" -ge "$3" ] && c=$R
  printf '%s%s%%%s' "$c" "$v" "$X"
}

kfmt() {
  [ -z "$1" ] && { printf '%s' '-'; return; }
  awk -v t="$1" 'BEGIN{ if (t>=1000000) printf "%.1fM", t/1000000; else if (t>=1000) printf "%.0fk", t/1000; else printf "%d", t }'
}

ctx_disp="ctx:$(paint "$ctx_pct" 40 70)"
[ -n "$ctx_used" ] && ctx_disp="$ctx_disp $(kfmt "$ctx_used")/$(kfmt "$ctx_size")"

if [ "${HERDR_ENV:-}" = "1" ] && [ -n "${HERDR_PANE_ID:-}" ] && [ -n "$ctx_used" ]; then
  (herdr pane report-metadata "$HERDR_PANE_ID" --source claude-statusline --token ctx="$(kfmt "$ctx_used")" >/dev/null 2>&1 &)
fi

printf '%b\n' "$model | $dir | $ctx_disp | 5h:$(paint "$h5" 60 85) | 7d:$(paint "$d7" 60 85)"
