---
name: extract-cowork-conversations
description: >
  Extract, search, and export Claude Cowork conversation threads from local
  audit.jsonl files stored on macOS. Use this skill whenever the user mentions
  Cowork conversations, Cowork history, wants to review past Cowork sessions,
  search Cowork chats, export Cowork threads, analyze Cowork usage patterns,
  or refers to "audit.jsonl" files. Also trigger when users ask about what
  they or someone else discussed in Cowork, or want to find a specific
  conversation from claude.ai Cowork mode.
---

# Extract Cowork Conversations

Claude Cowork stores full conversation logs locally as `audit.jsonl` files. This skill extracts them for review, search, and export. The bundled script at `scripts/extract.py` handles the heavy lifting — use it instead of writing extraction code from scratch.

## Where conversations live

```
~/Library/Application Support/Claude/local-agent-mode-sessions/
  {workspace-uuid}/
    {project-uuid}/
      local_{session-id}.json     <- metadata (title, date, model)
      local_{session-id}/
        audit.jsonl               <- full conversation (10KB–10MB+)
        .audit-key                <- present if encrypted
        uploads/                  <- files the user uploaded
```

Session metadata JSON files are small and contain: `sessionId`, `title`, `createdAt` (ms epoch), `initialMessage`, `model`, `cwd`, `userSelectedFolders`.

Each line in `audit.jsonl` is a JSON object with `type` field: `user`, `assistant`, `tool_use`, or `tool_result`. User content is a string. Assistant content is a list of content blocks (text, tool_use).

## Commands

Run the bundled script for all operations:

```bash
# List all sessions with titles and dates
python scripts/extract.py list

# Search sessions by keyword (searches metadata and audit content)
python scripts/extract.py search "PBIOLOGY"

# Print full conversation thread
python scripts/extract.py extract <session-id>

# Print only user messages (great for spotting correction patterns)
python scripts/extract.py extract <session-id> --users

# Export one session to markdown
python scripts/extract.py export <session-id> output.md

# Export all sessions to a directory
python scripts/extract.py export-all ./exported-sessions/
```

Session IDs look like `local_1de78112-b886-4ec9-b6d2-9347a7c31d4b`. Partial matches work — you can pass just the UUID portion.

## When to use each command

| Goal | Command |
|------|---------|
| "What Cowork sessions exist?" | `list` |
| "Find the session where we discussed X" | `search <keyword>` |
| "Show me that conversation" | `extract <session-id>` |
| "What corrections did the user make?" | `extract <session-id> --users` |
| "Save this conversation for later" | `export <session-id> <file>` |
| "Export everything" | `export-all <dir>` |

## Tips

- Audit files can be 10MB+. The script reads line-by-line to avoid memory issues.
- Files with `.audit-key` present may be encrypted and unreadable.
- The `--users` flag is especially useful for friction analysis — it shows the user's correction patterns without assistant noise.
- `cowork_settings.json` contains workspace settings, not conversations.
- Timestamps in metadata are milliseconds since epoch.
