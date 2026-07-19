#!/usr/bin/env bash
# PreToolUse guard for mcp__workos__mutate: hard-deny billing / paid-feature
# operations (personal credit card is on the WorkOS account), force an explicit
# ask on any other confirmation-token (destructive) call. Deterministic — runs
# before the tool, independent of model behavior.
set -euo pipefail

input=$(cat)
op=$(printf '%s' "$input" | jq -r '.tool_input.operation // ""')
token=$(printf '%s' "$input" | jq -r '.tool_input.confirmation_token // ""')

# Paid features / billing surface: custom domain ($99/mo), SSO + Directory Sync
# connections ($125/ea), Radar, audit-log streaming/SIEM, and anything that
# smells like plan/payment management. Case-insensitive substring match.
billing_pattern='billing|payment|invoice|subscription|checkout|purchase|upgrade|plan|domain|connection|directory|radar|audit|siem|stream|datadog'

if printf '%s' "$op" | grep -qiE "$billing_pattern"; then
  jq -n --arg op "$op" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ("workos-billing-guard: \"" + $op + "\" matches the billing/paid-feature blocklist and is hard-denied. If this is genuinely intended, do it in the WorkOS dashboard yourself or edit ~/.claude/hooks/workos-billing-guard.sh.")
    },
    systemMessage: ("⛔ workos-billing-guard denied mutation: " + $op)
  }'
  exit 0
fi

if [ -n "$token" ]; then
  jq -n --arg op "$op" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: ("workos-billing-guard: \"" + $op + "\" is a confirmation-gated (destructive) WorkOS operation — explicit user approval required.")
    }
  }'
  exit 0
fi

exit 0
