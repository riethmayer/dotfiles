# Daily Notes

## Path Format

```
2 - Areas/Journal/YYYY/MM-MMMM/YYYY-MM-DD-dddd.md
```

Example: `2 - Areas/Journal/2026/03-March/2026-03-15-Sunday.md`

## Open in Obsidian

```bash
obsidian-cli daily -v riethmayer
```

## Creating Programmatically

When creating a daily note via Write tool:

```markdown
---
date: YYYY-MM-DD HH:mm
tags: []
hubs:
urls:
---

# YYYY-MM-DD-dddd

## What happened

### Strategy
- (items from brag-book)

### Culture
- (items from brag-book)

### Execution
- (items from brag-book)

## Notes

## Tasks
```

**Skip the Excalidraw embed** — the original template includes `![[filename.svg]]` + compressed-json block, but that requires Excalidraw plugin to initialize and adds noise programmatically.

## Brag-Book Integration

When creating or appending to daily notes, check for brag-book entries:

```bash
cat ~/.local/share/brag-book/YYYY-MM-DD.jsonl 2>/dev/null
```

Each line is JSON:
```json
{"timestamp": "HH:MM:SS", "category": "strategy|culture|execution", "summary": "...", "source": "hook|manual"}
```

Group entries by category under "What happened". If no brag-book file exists for the date, skip the section entirely.

## Navigation

The original template includes nav links. If adding them:

```markdown
[[YYYY-MM-DD|Back]] [[YYYY-MM-DD|Forward]] [[Week WW of YYYY|Week WW]] [[YYYY-MM|Month]] [[QN of YYYY|QN]] [[Year of YYYY|YYYY]]
```
