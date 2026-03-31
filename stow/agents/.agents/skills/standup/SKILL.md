---
name: standup
description: >
  Extract standup notes from git activity across all active worktrees, dotfiles, and skills repos.
  Use when the user says "standup", "standup notes", "what did I do", "daily update", "morning update",
  or wants a summary of recent development work. Scans git history, brag-book entries, and worktrees
  to compile a structured standup report.
---

# Standup Notes Generator

Compile a standup report from real development activity across multiple repos and worktrees.

## Data Sources

Scan these locations in parallel for recent git activity:

### 1. EagleEye Worktrees
Path: `~/code/eagleeye/.claude/worktrees/`

Each subdirectory is a git worktree. For each:
- Run `git log --oneline --since="<since>" --author="jan" --no-merges` (short output)
- Run `git log --since="<since>" --author="jan" --no-merges --format="%s"` for commit messages
- Capture the branch name (`git branch --show-current`)
- Note any open PRs (`gh pr view --json number,state,title,url 2>/dev/null`)

Skip worktrees with no recent commits silently.

### 2. Standalone Repos
Scan these the same way:
- `~/dotfiles/`
- `~/code/skills/`
- `~/code/eagleeye/` (main repo, not worktrees)

### 3. Brag Book
Path: `~/.local/share/brag-book/`

Read today's JSONL file (`YYYY-MM-DD.jsonl`). Each line is a JSON object with:
- `summary` — what was done
- `git_repo` / `git_branch` — where
- `timestamp` — when
- `category` — strategy | culture | execution

Group entries by repo/branch. Use these to fill gaps that git commits miss (e.g., reviews, debugging sessions, config changes that weren't committed).

## Time Window

- **Weekday**: since yesterday (or last working day if Monday)
- **`<since>` calculation**: Use `yesterday` on Tue-Fri. On Monday, use `last friday`.
- The user may override with "since Tuesday" or "last 3 days" — respect that.

## Output Format

Output a clean markdown standup. Group by workstream (branch/worktree), not by repo.

```markdown
## Standup — YYYY-MM-DD

### Done
- **branch-name**: concise summary of commits (reference PR if exists)
- **branch-name**: another workstream
- **dotfiles**: what changed

### In Progress
- **branch-name**: uncommitted work or open PRs awaiting review

### Blocked / Open
- anything flagged in brag-book or unmerged PRs with changes requested
```

### Guidelines

- **Deduplicate**: brag-book and git often overlap — prefer the git commit message, use brag-book for context
- **Summarize**: don't list every commit — group related commits into one bullet per workstream
- **PR references**: include `#123 (status)` when a PR exists
- **Skip noise**: ignore merge commits, dependabot, automated commits
- **Be concise**: each bullet should be one line, focused on *what* was accomplished

## Execution

1. Determine `<since>` based on day of week
2. Launch parallel subagents (or parallel bash commands) to scan all data sources — worktrees can be slow, parallelism matters
3. Collect results, deduplicate, group by workstream
4. Output the standup in the format above
5. If the user's Obsidian journal exists for today (`~/obsidian/riethmayer/2 - Areas/Journal/YYYY/MM-Month/YYYY-MM-DD-DayName.md`), ask if they want it appended there
