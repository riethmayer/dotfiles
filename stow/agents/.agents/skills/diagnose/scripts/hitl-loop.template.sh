#!/usr/bin/env bash
# Human-in-the-loop reproduction loop.
# Copy this file, edit the steps below, and run it.
# The agent runs the script; the user follows prompts in their terminal.
#
# Usage:
#   bash hitl-loop.template.sh
#
# Two helpers:
#   step "<instruction>"               → show instruction, wait for Enter
#   capture VAR "<question>"           → show question, read single-line response into VAR
#   capture_multiline VAR "<question>" → read until a line containing only "EOF"; preserves newlines
#
# At the end, captured values are printed as KEY=VALUE for the agent to parse.

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Enter when done] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

capture_multiline() {
  local var="$1" question="$2" line acc=""
  printf '\n>>> %s\n    [paste, then a line with only EOF to finish]\n' "$question"
  while IFS= read -r line; do
    [[ "$line" == "EOF" ]] && break
    acc+="$line"$'\n'
  done
  printf -v "$var" '%s' "${acc%$'\n'}"
}

# --- edit below ---------------------------------------------------------

step "Open the app at http://localhost:3000 and sign in."

capture ERRORED "Click the 'Export' button. Did it throw an error? (y/n)"

capture_multiline ERROR_MSG "Paste the error message / stack trace (or 'none'):"

# --- edit above ---------------------------------------------------------

printf '\n--- Captured ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
