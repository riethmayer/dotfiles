# Granola Meeting Integration

Pull meeting transcripts via Granola MCP tools and save as vault notes.

## MCP Tools

| Tool | Description |
|------|-------------|
| `mcp__claude_ai_Granola__list_meetings` | List recent meetings |
| `mcp__claude_ai_Granola__get_meeting_transcript` | Get full transcript by ID |
| `mcp__claude_ai_Granola__get_meetings` | Get meeting details |
| `mcp__claude_ai_Granola__query_granola_meetings` | Search meetings by query |

## Workflow

1. List or search meetings via MCP
2. Get transcript for the target meeting
3. Create note at `3 - Resources/Granola/YYYY-MM-DD - Meeting Title.md`
4. Summarize key points, extract action items

## Note Template

```markdown
---
date: YYYY-MM-DD
tags:
  - meeting
hubs:
  - "[[relevant-hub]]"
urls: []
---

# Meeting Title

## Participants
- Name 1
- Name 2

## Key Points
- Point 1
- Point 2

## Action Items
- [ ] Action 1 — @owner
- [ ] Action 2 — @owner

## Notes
(condensed/summarized transcript — not raw dump)
```

Keep transcripts summarized. Raw transcripts are large and reduce note utility.
