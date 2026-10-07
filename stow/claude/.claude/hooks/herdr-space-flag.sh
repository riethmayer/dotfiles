#!/bin/bash
#
# Claude Code hook (PreToolUse Bash|Skill, PostToolUse Bash|Edit|Write):
# flag the herdr space this session runs in with status emojis so the
# sidebar shows which spaces deploy and which touch the data warehouse.
#
#   🚀  a deploy is running or was attempted: gh pr merge, gh run watch,
#       gh workflow run, gcloud run deploy, terragrunt/terraform apply,
#       kubectl/helm/firebase/fly deploys, the /ship skill
#   🔥  the space changes the warehouse: sqlmesh plan/run/migrate/…,
#       /sqlmesh/deploy or /sqlmesh/ack PR comments, the sqlmesh skills,
#       or any edit inside a SQLMesh project (dir with config.yaml naming
#       gateways + models/)
#   ✅  the flagged deploy finished successfully (replaces 🚀): gh run
#       watch/view reporting success, "Apply complete!", gcloud "has been
#       deployed", kubectl "successfully rolled out", firebase "Deploy
#       complete!". Only set while 🚀 is present, so a green CI run on a
#       PR never counts as a deploy.
#
# Label shape: "<slot> <flags> <name>". The treehouse slot prefix written by
# the space-stamp herdr plugin is kept; flags are one token, deploy state
# first (🚀 or ✅), then 🔥. Flags are sticky: clear them by renaming the
# space (prefix+ctrl+r). No-op outside herdr (HERDR_WORKSPACE_ID unset).
# Never fails the tool call.

input=$(cat)
[ -n "${HERDR_WORKSPACE_ID:-}" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0
herdr_bin="${HERDR_BIN_PATH:-herdr}"

field() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }
event=$(field '.hook_event_name // ""')
tool=$(field '.tool_name // ""')
cmd=$(field '.tool_input.command // ""')
skill=$(field '.tool_input.skill // ""')
file=$(field '.tool_input.file_path // ""')

# Editing or testing this hook must not flag the space.
case "$cmd" in *herdr-space-flag*|*hookSpecificOutput*|*tool_response*) exit 0 ;; esac

DEPLOY_RE='gh[[:space:]]+pr[[:space:]]+merge|gh[[:space:]]+run[[:space:]]+watch|gh[[:space:]]+workflow[[:space:]]+run|gh[[:space:]]+run[[:space:]]+(view|list|rerun).*--workflow[=[:space:]]["'"'"']?[^[:space:]"'"'"']*(deploy|-cd|release)|gcloud[[:space:]]+(run[[:space:]]+(deploy|services[[:space:]]+update)|builds[[:space:]]+submit|app[[:space:]]+deploy|functions[[:space:]]+deploy)|terragrunt[[:space:]]+(run-all[[:space:]]+)?apply|terraform[[:space:]]+apply|kubectl[[:space:]]+(apply|rollout)|helm[[:space:]]+(upgrade|install)|firebase[[:space:]]+deploy|fly[[:space:]]+deploy|vercel.*--prod|/sqlmesh/(deploy|ack)'
SQLMESH_RE='sqlmesh([[:space:]]+[^[:space:]]+)*[[:space:]]+(plan|run|migrate|invalidate|janitor|rollback|destroy|create_external_models)([[:space:]]|$)|--restate-model|/sqlmesh/(deploy|ack)|gh[[:space:]]+workflow[[:space:]]+run[[:space:]]+["'"'"']?sqlmesh'
# Commands whose output can prove the deploy landed.
MONITOR_RE='gh[[:space:]]+run[[:space:]]+(watch|view)|gcloud[[:space:]]+run[[:space:]]+deploy|terragrunt[[:space:]]+(run-all[[:space:]]+)?apply|terraform[[:space:]]+apply|kubectl[[:space:]]+rollout[[:space:]]+status|helm[[:space:]]+(upgrade|install)|firebase[[:space:]]+deploy|fly[[:space:]]+deploy'
SUCCESS_RE="completed with 'success'|completed/success|\"conclusion\": ?\"success\"|Apply complete!|has been deployed|successfully rolled out|Deploy complete!|Deployment complete|deployed successfully"
PENDING_RE="in_progress|queued|waiting|pending|/failure|/cancelled|'failure'|'cancelled'|\"failure\"|\"cancelled\"|/-[[:space:]]"

in_sqlmesh_project() {
  local d n=0 cfg
  d=$(dirname "$1")
  while [ "$d" != "/" ] && [ "$d" != "." ] && [ $n -lt 12 ]; do
    for cfg in "$d/config.yaml" "$d/config.yml" "$d/config.py"; do
      if [ -f "$cfg" ] && [ -d "$d/models" ] && grep -qiE 'gateway|sqlmesh' "$cfg" 2>/dev/null; then
        return 0
      fi
    done
    d=$(dirname "$d"); n=$((n + 1))
  done
  return 1
}

want_rocket=0 want_fire=0 want_done=0
case "$event/$tool" in
  PreToolUse/Bash)
    printf '%s' "$cmd" | grep -qiE "$DEPLOY_RE" && want_rocket=1
    printf '%s' "$cmd" | grep -qiE "$SQLMESH_RE" && want_fire=1
    ;;
  PreToolUse/Skill)
    case "$skill" in
      ship|*:ship|deploy-gke-airflow|*:deploy-gke-airflow) want_rocket=1 ;;
      sqlmesh-prod-restate-model|*:sqlmesh-prod-restate-model) want_fire=1 ;;
    esac
    ;;
  PostToolUse/Bash)
    if printf '%s' "$cmd" | grep -qiE "$MONITOR_RE"; then
      resp=$(field '.tool_response // "" | if type == "string" then . else (.stdout // .output // tojson) end')
      if printf '%s' "$resp" | grep -qE "$SUCCESS_RE" && ! printf '%s' "$resp" | grep -qE "$PENDING_RE"; then
        want_done=1
      fi
    fi
    ;;
  PostToolUse/Edit|PostToolUse/Write|PostToolUse/MultiEdit)
    case "$file" in
      *.md) ;;
      ?*) in_sqlmesh_project "$file" && want_fire=1 ;;
    esac
    ;;
esac
[ $((want_rocket + want_fire + want_done)) -gt 0 ] || exit 0

label=$("$herdr_bin" workspace get "$HERDR_WORKSPACE_ID" 2>/dev/null | jq -r '.result.workspace.label // ""' 2>/dev/null)
[ -n "$label" ] || exit 0

# Split "<slot> <flags> <name>"; slot and flags are optional.
rest=$label slot="" flags=""
if [[ $rest =~ ^([0-9]+)\ (.+)$ ]]; then slot="${BASH_REMATCH[1]}"; rest="${BASH_REMATCH[2]}"; fi
first="${rest%% *}"
if [ "$first" != "$rest" ]; then
  t="${first//🚀/}"; t="${t//✅/}"; t="${t//🔥/}"
  if [ -z "$t" ]; then flags="$first"; rest="${rest#* }"; fi
fi

deploy=""
case "$flags" in *🚀*) deploy="🚀" ;; *✅*) deploy="✅" ;; esac
fire=""
case "$flags" in *🔥*) fire="🔥" ;; esac

if [ $want_done -eq 1 ] && [ "$deploy" = "🚀" ]; then deploy="✅"; fi
if [ $want_rocket -eq 1 ]; then deploy="🚀"; fi
if [ $want_fire -eq 1 ]; then fire="🔥"; fi

new_flags="${deploy}${fire}"
new="${slot:+$slot }${new_flags:+$new_flags }$rest"
[ "$new" != "$label" ] || exit 0

"$herdr_bin" workspace rename "$HERDR_WORKSPACE_ID" "$new" >/dev/null 2>&1 \
  && echo "herdr-space-flag: $HERDR_WORKSPACE_ID -> '$new'" >&2
exit 0
