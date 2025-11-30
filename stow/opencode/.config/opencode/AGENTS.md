# Global OpenCode Instructions

Personal preferences applied across all projects.

## Brag Book

- Automatically tracks work sessions in `$XDG_DATA_HOME/brag-book/`
- Daily JSONL files: `{date}.jsonl` (e.g., `2025-11-30.jsonl`)
- Use `/brag <description>` command to add manual entries
- Use `brag` CLI command to add entries or list recent work
- Session auto-capture via plugin on idle/completion
- Shares data format with Claude brag book

## Planning

When a repo has `.planning/` directory:
1. Check `.planning/README.md` for current sprint status
2. Look for incomplete sprints (unchecked `[ ]` items)
3. Read the sprint file before starting work
4. A sprint is complete when `sprint-{NN}-{name}-summary.md` exists

## Tool Preferences

Prefer these tools over defaults:
- `gh` over `git` for GitHub operations
- `rg` (ripgrep) over `grep`
- `fd` over `find`
- `bat` over `cat`
- `zoxide` (`z`) over `cd`
- `lazygit` for complex git operations
- `fzf` for fuzzy finding

## Git

- Branch prefix: `riethmayer/`
- Concise commits, sacrifice grammar
- Use gh CLI for GitHub (PRs, issues)

## Style

- Be concise
- End plans with unresolved questions
