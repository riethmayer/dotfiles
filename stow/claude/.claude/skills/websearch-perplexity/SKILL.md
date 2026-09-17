---
name: websearch-perplexity
description: Explains why WebSearch results come from Perplexity and how to turn that off. Use when the user asks where web search results come from, why WebSearch says "answered by Perplexity", or wants to disable or debug the Perplexity search routing.
---

# websearch-perplexity

This plugin's function hook (`hooks/websearch.ts`) answers every `WebSearch`
call with `pplx search web`, returned in WebSearch's own result shape. When
pplx is missing, the key is missing, the call fails, or there are no hits, the
native WebSearch runs instead.

- Needs `CLAUDE_CODE_ENABLE_FUNCTION_HOOKS=1` (function hooks are early access).
- Key: `PERPLEXITY_API_KEY`, else `op read "op://machines/Perplexity API Key/credential"`
  via the machine's 1Password service account (token: Keychain `op-service-account-token`).
- Turn off for one session: `PPLX_WEBSEARCH=0`. For good:
  `claude plugin disable websearch-perplexity@skills-dir`.
- Debug: `claude --debug`; skipped hooks are only logged there.
- After a Claude Code update: `/plugin-types .claude/types` in this folder.
