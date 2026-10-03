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

- Prefer the treehouse pool when the CLI is installed: `treehouse get --lease --json --lease-holder <label>` from the repo → use `.path`. Lease arrives detached at the default tip — `git switch <branch>` / `git switch -c <new>` before committing. `treehouse return <path>` once the branch is pushed.
- Fallback (no treehouse): create under `.claude/worktrees/<short-name>` inside the repo (not sibling dirs)
- Either way: copy `.claude/settings.local.json` and `.env`

## Scratch, Briefs & Reports

- Never `/tmp` for anything worth keeping: agent briefs, reports, handoffs, PR-body drafts, notes. Write them to today's Obsidian day folder, one subfolder per workstream: `"$(node ~/skills/scripts/journal.mjs paths | jq -r .dayDir)/<topic>/"` (e.g. `founder-profile/`)
- `/tmp` only for throwaway command output nobody rereads (DOM dumps, patch diffs), and never personal data
- When briefing a spawned agent, give it the vault path for its report

## Pull Requests

- Every PR body follows `/pr` (jan-ship): Summary (diff blocks / pseudocode / file trees), Evidence (before/after), Merge Danger (door + blast radius). Never `gh pr create --fill`.
- After `gh pr create` (non-draft), default to `/ship` (runs `/check-pr`, then squash-merge + deploy-monitor) unless told otherwise this turn.
- Enforcement is deterministic, not memory: a PostToolUse hook (`~/.claude/hooks/gh-pr-create-ship.sh`) surfaces this on every create in earlybirdvc/eagleeye; GitHub branch protection is the hard gate that blocks merging anything red or behind.

## Presentation & Visuals

- Always apply brand guidelines (earlybird plugin) for any visual
- Presentations are single-file HTML decks via the `html-presentation` skill (earlybird plugin); there is no pptx skill
- Add "strictly confidential" to first slide top-right

## CLI & API Values

- Before using a flag, subcommand or enum value you have not seen work this session, read `--help` / `<tool> help <cmd>` or list the valid values. After one rejection, look it up; never retry a variation. (retro topic `cli-syntax-guessing`, 2 sessions)

## Misc

- `sonar "question"` asks Perplexity Sonar (default `sonar-pro`; `-m sonar-deep-research` for long research). WebSearch already routes to Perplexity via the `websearch-perplexity` plugin
- When copying to clipboard, omit markdown fences — just raw content
- When reading excalidraw files, extract relevant nodes instead of loading fully
- Assume Neovide/nvim as code editor
