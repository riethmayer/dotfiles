# Claude Code Instructions

Be extremely concise, sacrifice grammar for concision.

- Do NOT add Claude Code footer or Co-Authored-By to commit messages

## Planning

When a repo has `.planning/` directory:

1. Check `.planning/README.md` for current sprint status
2. Look for incomplete sprints (unchecked `[ ]` items)
3. Read the sprint file before starting work
4. A sprint is complete when `sprint-{NN}-{name}-summary.md` exists

End plans with unresolved questions (extremely concise).

## Brag Book

- Track work in `~/.local/share/brag-book/`
- Daily JSONL files: `{date}.jsonl`
- Categories: strategy, culture, execution
- Entry format: `{"timestamp": "HH:MM:SS", "category": "...", "summary": "...", "source": "hook|manual", "session_id": "..."}`
- Use `brag` command manually, `brag-capture-stop` to disable hook

## Worktrees

- Create under `.claude/worktrees/<short-name>` inside the repo (not sibling dirs)
- Copy `.claude/settings.local.json` and `.env`

## Presentation & Visuals

- Always apply brand guidelines (earlybird plugin) for any visual
- Use pptx skill for presentations
- Add "strictly confidential" to first slide top-right

## Misc

- When copying to clipboard, omit markdown fences — just raw content
- When reading excalidraw files, extract relevant nodes instead of loading fully
- Assume Neovide/nvim as code editor
