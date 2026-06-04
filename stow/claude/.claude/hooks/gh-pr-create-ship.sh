#!/bin/bash
#
# PostToolUse(Bash) hook: after a SUCCESSFUL, non-draft `gh pr create` in the
# earlybirdvc/eagleeye repo, deterministically remind the agent to run /ship.
#
# Why a hook and not auto-memory: memory is relevance-recalled (probabilistic).
# A hook fires on the tool event every time, so the ship protocol no longer
# depends on the model "remembering". This is strong guidance, not a hard gate
# (PostToolUse cannot block) - the hard safety gate is GitHub branch protection,
# which prevents merging anything red or behind regardless of this hook.
#
# Reads the tool-call JSON on stdin. On match, prints additionalContext JSON to
# stdout (exit 0). Otherwise exits 0 silently. Never errors the turn.

input=$(cat)

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)

# Ignore meta/test commands that merely mention the hook or carry raw hook
# payloads (e.g. testing or editing this hook). A real `gh pr create` never
# contains these tokens, so this only suppresses self-triggering noise.
case "$cmd" in
  *gh-pr-create-ship*|*hookSpecificOutput*|*tool_response*|*tool_input*) exit 0 ;;
esac

# Must be a `gh pr create`, and must NOT be a draft.
printf '%s' "$cmd" | grep -qE 'gh[[:space:]]+pr[[:space:]]+create' || exit 0
printf '%s' "$cmd" | grep -qE -- '--draft' && exit 0

# Require a PR URL in the payload. This proves the create SUCCEEDED (gh prints
# the URL on success) AND scopes the nudge to the eagleeye repo - greps the
# whole stdin so it does not depend on the exact result field name across
# Claude Code versions (tool_response vs tool_result).
prurl=$(printf '%s' "$input" | grep -oE 'https://github\.com/earlybirdvc/eagleeye/pull/[0-9]+' | head -1)
[ -n "$prurl" ] || exit 0

prnum=${prurl##*/}

jq -n --arg n "$prnum" --arg url "$prurl" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: ("Non-draft PR #" + $n + " (" + $url + ") was just created in earlybirdvc/eagleeye. Per the ship protocol, default to running the /ship skill now (it runs /check-pr, then squash-merge + deploy-monitor) unless the user has said otherwise this turn. Suggested invocation: /ship " + $n)
  }
}'
