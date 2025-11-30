In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## Git & GitHub

- Use `gh` CLI for GitHub operations (not `git` for PR/issue ops)
- Branch prefix: `riethmayer/`
- End plans with unresolved questions
- Commit early and often, atomic commits
- Do NOT add Claude Code footer or Co-Authored-By to commit messages

## Search

- Use fzf whenever searching for things

## YAML

- Create valid YAML - avoid `->` in lists as it breaks parsing

## Plans

- At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise and sacrifice grammer for the sake of concision.

## Brag Book

- Track work in `$XDG_DATA_HOME/brag-book/` (`~/.local/share/brag-book/`)
- Daily JSONL files: `{date}.jsonl` (e.g., `2025-11-20.jsonl`)
- Categories: strategy, culture, execution
- Entry format: `{"timestamp": "HH:MM:SS", "category": "...", "summary": "...", "source": "hook|manual", "session_id": "..."}`
- Use `brag` command to add entries manually
- Stop hook auto-captures via `brag-capture-stop` (uses `claude -p` CLI)
