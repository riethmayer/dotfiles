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

Group by workstream/topic (not by repo). Use rich narrative bullets — not raw commit messages.

### Style (match existing journal entries)

- **Bold workstream header** followed by narrative bullets
- PR links as `([#123](https://github.com/earlybirdvc/eagleeye/pull/123))`
- Group related commits into one bullet (e.g., "Fixed eval runner CF path + trigger")
- Include context: what problem was solved, not just what file changed
- Mix shipped PRs + in-progress work under the same workstream

### Guidelines

- **Deduplicate**: brag-book and git often overlap — prefer the git commit message, use brag-book for context
- **Summarize**: don't list every commit — group related commits into one bullet per workstream
- **PR references**: include `([#123](url))` with full GitHub URL for Obsidian clickability
- **Skip noise**: ignore merge commits, dependabot, automated commits
- **Be concise**: each bullet should be one line, focused on *what* was accomplished

## Obsidian Journal Integration

Always write the standup to today's Obsidian daily note. Never ask — just do it.

### Journal path

```
~/obsidian/riethmayer/2 - Areas/Journal/YYYY/MM-MMMM/YYYY-MM-DD-DayName.md
```

Example: `2026-04-13-Monday.md` in `2026/04-April/`

### Daily note structure

The daily note has this structure (created by Obsidian template):

```markdown
---
date: YYYY-MM-DD HH:MM
tags: []
...excalidraw frontmatter...
---

[[prev|Back]] [[next|Forward]] [[Week N|Week N]] ...

# YYYY-MM-DD-DayName

## Morning Standup

### Intentions
-

### Done
-

### Focus for today
-

---

![[YYYY-MM-DD-DayName.svg]]

%%
## Drawing
...excalidraw data...
%%
```

### Where to write

Replace the content of `### Done` section (between `### Done` and `### Focus for today`).
Leave `### Intentions` and `### Focus for today` untouched — those are manual entries.

If the daily note doesn't exist yet, create it with the full template structure
(frontmatter, nav links, headings, excalidraw embed).

If `### Done` already has content, **append** new items — don't overwrite existing entries.
The user may run `/standup` multiple times during the day.

### After writing

Show the user the standup output in the conversation too (not just silently writing to file).

## Execution

1. Determine `<since>` based on day of week (or last daily note with content)
2. Launch parallel subagents (or parallel bash commands) to scan all data sources — worktrees can be slow, parallelism matters
3. Also fetch merged PRs: `gh pr list --state merged --author riethmayer --search "merged:>YYYY-MM-DD" --json number,title,url,mergedAt`
4. Collect results, deduplicate, group by workstream
5. Write to today's Obsidian daily note `### Done` section
6. Output the standup in the conversation
