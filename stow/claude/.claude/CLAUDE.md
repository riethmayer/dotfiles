- Concise commits, sacrifice grammar
- Use gh CLI for GitHub
- Branch prefix: riethmayer/
- End plans with unresolved questions

## Planning

When a repo has `.planning/` directory:
1. Check `.planning/README.md` for current sprint status
2. Look for incomplete sprints (unchecked `[ ]` items)
3. Read the sprint file before starting work
4. A sprint is complete when `sprint-{NN}-{name}-summary.md` exists

## Brag Book

- Track work in `$XDG_DATA_HOME/brag-book/` (`~/.local/share/brag-book/`)
- Daily JSONL files: `{date}.jsonl` (e.g., `2025-11-20.jsonl`)
- Categories: strategy, culture, execution
- Entry format: `{"timestamp": "HH:MM:SS", "category": "...", "summary": "...", "source": "hook|manual", "session_id": "..."}`
- Use `brag` command to add entries manually
- Stop hook auto-captures via `brag-capture-stop` (uses `claude -p` CLI)
