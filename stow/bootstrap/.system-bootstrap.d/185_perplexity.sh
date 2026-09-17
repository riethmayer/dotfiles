#!/bin/bash

# Perplexity tooling for agents and the terminal.
#
# - pplx: Perplexity's search CLI. The websearch-perplexity Claude plugin
#   (stow/claude/.claude/skills/websearch-perplexity) calls ~/.local/bin/pplx
#   for every WebSearch. The installer verifies checksums; `pplx update` owns
#   upgrades, so install only when missing.
# - llm + llm-perplexity: backs the `sonar` wrapper (stow/scripts/bin/sonar).
# - pplx-cli skill: third-party, reinstalled from upstream rather than copied
#   into this repo.
#
# The API key lives in 1Password (vault `machines`, item "Perplexity API Key")
# and is read per call through the service account (ADR-010). Nothing here
# writes it to disk. Idempotent.

set -euo pipefail

PPLX_INSTALL_PATH="${PPLX_INSTALL_PATH:-$HOME/.local/bin/pplx}"

# pplx
if [ -x "$PPLX_INSTALL_PATH" ]; then
    echo "perplexity: pplx already installed ($("$PPLX_INSTALL_PATH" --version 2>/dev/null || echo unknown)); \`pplx update\` owns upgrades"
else
    command -v curl >/dev/null 2>&1 || { echo "perplexity: curl not found" >&2; exit 1; }
    curl -fsSL https://github.com/perplexityai/perplexity-cli/releases/latest/download/install.sh \
        | PPLX_INSTALL_PATH="$PPLX_INSTALL_PATH" sh
fi

# llm + llm-perplexity
command -v uv >/dev/null 2>&1 || { echo "perplexity: uv not found (mise install)" >&2; exit 1; }
if uv tool list 2>/dev/null | grep -q '^llm '; then
    echo "perplexity: llm already installed"
else
    uv tool install llm
fi
llm_bin="$(uv tool dir --bin)/llm"
if "$llm_bin" plugins 2>/dev/null | grep -q '"name": "llm-perplexity"'; then
    echo "perplexity: llm-perplexity already installed"
else
    "$llm_bin" install llm-perplexity
fi

# pplx-cli skill (global, Claude Code)
if [ -f "$HOME/.claude/skills/pplx-cli/SKILL.md" ]; then
    echo "perplexity: pplx-cli skill already installed"
else
    command -v npx >/dev/null 2>&1 || { echo "perplexity: npx not found (mise install)" >&2; exit 1; }
    npx --yes skills add perplexityai/api-platform-developers -g -s pplx-cli -a claude-code -y
fi

# The key check needs the service account; report, never fail the bootstrap.
if [ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]; then
    OP_SERVICE_ACCOUNT_TOKEN="$(security find-generic-password -s op-service-account-token -w 2>/dev/null || true)"
fi
if [ -n "$OP_SERVICE_ACCOUNT_TOKEN" ] \
    && OP_SERVICE_ACCOUNT_TOKEN="$OP_SERVICE_ACCOUNT_TOKEN" op item get "Perplexity API Key" --vault machines >/dev/null 2>&1; then
    echo "perplexity: API key reachable in 1Password (machines)"
else
    echo "perplexity: API key not reachable; run \`mise run 1password\` and put \"Perplexity API Key\" (field credential) in the machines vault" >&2
fi

echo "Perplexity setup complete!"
