---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up. Use whenever the user says "handoff", "hand this off", "summarize for a fresh session", "compact this for another agent", or otherwise wants to transfer ongoing work to a new context — even if they don't use the exact word "handoff". Optional argument describes what the next session will focus on.
---

# Handoff

Write a handoff document so a fresh agent can continue this work without you.

## Where to save

Save to the OS temp directory, NOT the current workspace.

- macOS/Linux: `$TMPDIR` if set, else `/tmp`
- Filename: `handoff-<slug>-<YYYY-MM-DD-HHMM>.md` where `<slug>` reflects the next session's focus

After writing, print the absolute path so the user can open or copy it.

## Tailoring to the argument

If the user passed an argument after `/handoff`, treat it as a description of what the next session will focus on. Lead the doc with that objective and bias every section (next steps, suggested skills, gotchas) toward it. Drop context that's not load-bearing for that focus.

No argument → write a general handoff of the current work.

## Structure

Use this template. Drop sections that have nothing to say — don't pad.

```markdown
# Handoff: <one-line title>

**Next session focus:** <from argument, or inferred from conversation>
**Working directory:** <cwd>
**Branch:** <git branch if in a repo>

## Objective
<1–2 sentences. What does the next agent need to accomplish?>

## State of play
- What's done
- What's in progress
- What's blocked, and on what

## Relevant artifacts
Reference, don't duplicate. Use paths or URLs.
- `path/to/file.ts:42` — what's there and why it matters
- `docs/briefs/2026-05-foo.md` — decisions already made
- PR #123 / issue #456 / commit abc1234

## Next steps
1. Concrete action
2. Concrete action
3. …

## Suggested skills
Skills the next agent should invoke. One line of rationale each.
- `skill-name` — why it fits
- `another-skill` — why it fits

## Open questions
- Unresolved decisions the next agent needs to make or ask the user about

## Gotchas
- Non-obvious traps: failed approaches, hidden constraints, brittle paths, env quirks
```

## What NOT to include

- **Don't duplicate** content already in PRDs, plans, ADRs, briefs, issues, commits, or diffs. Reference them by path or URL. The next agent can read them.
- **Don't include sensitive data**: API keys, tokens, passwords, secrets, private keys, PII (emails, phone numbers, addresses of third parties). Replace with `<REDACTED>` and note what was redacted (e.g., `<REDACTED: GCP service account key>`).
- **Don't include conversation noise**: backtracking, false starts, polite chitchat. Only what's needed to continue.
- **Don't restate the obvious**: the next agent will read CLAUDE.md and the repo. Skip stuff they'll see on arrival.

## Style

The next agent is competent — give them enough to orient, not a novel.

- Bullets over prose
- Paths and URLs over restated content
- Specific over general (`src/auth/token.ts:88 returns null when scope is empty` beats `there's a bug in auth`)
- Sacrifice grammar for concision

## Suggested skills section: how to pick

Pull from two sources:

1. **Skills used productively this session** — if the work involved e.g. `debug-like-expert` or `frontend-design`, the next agent likely needs them too.
2. **Skills that fit the upcoming work** — if the next focus is reviewing a PR, suggest `check-pr` or `code-review`. If it's domain modeling, suggest `domain-architecture` or `event-storming`.

If you don't know what skills are available, list the ones you used and add a note: "run `find-skills` to discover more relevant skills for this focus."
