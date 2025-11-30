- Concise commits, sacrifice grammar
- Use gh CLI for GitHub
- Branch prefix: riethmayer/
- End plans with unresolved questions

## Brag Book

- Track work in `$XDG_DATA_HOME/brag-book/` (`~/.local/share/brag-book/`)
- Daily JSONL files: `{date}.jsonl` (e.g., `2025-11-20.jsonl`)
- Categories: strategy, culture, execution
- Entry format: `{"timestamp": "HH:MM:SS", "category": "...", "summary": "...", "source": "hook|manual", "session_id": "..."}`
- Use `brag` command to add entries manually
- Stop hook auto-captures via `brag-capture-stop` (uses `claude -p` CLI)
