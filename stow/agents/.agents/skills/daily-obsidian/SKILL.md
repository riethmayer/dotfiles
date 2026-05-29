---
name: daily-obsidian
description: Personal extension of the team's /daily skill — files the polished HTML brief into an Obsidian vault's per-date folder. Use when the user says "/daily-obsidian", "daily into obsidian", or asks to file the daily brief into their vault. Only activates when the OBSIDIAN_VAULT_DAILY_JOURNAL environment variable is set.
---

# Daily — Obsidian extension

A personal extension of the team's `/daily` skill that:

1. **Loads the user's current-quarter OKRs** from Linear and pushes them to the top of every brief — each OKR closes with one concrete action today, not a status read-out.
2. **Drops the polished HTML brief into the Obsidian vault** under a **per-date folder**, so every artifact produced that day (brief + meeting notes + ad-hoc HTMLs) lives in one place — and each filename carries the date so any single file is shareable standalone.

## Why this skill exists — and why it's a template

The team owns `/daily`. Forking it for personal preferences pollutes the team skill and creates merge churn. The cleaner pattern: **leave the team skill alone, write a thin personal skill that calls it and post-processes the output.**

This skill is a worked example of that pattern. Teammates can copy this folder, rename it, swap the post-processing step, and end up with their own personal layer on top of `/daily` — no fork required.

The whole pattern: **detect → load → delegate → augment.**

1. **Detect** — read an env var that the personal user (not the team) sets.
2. **Load** — fetch personal context that doesn't belong in the team skill (here: the user's current-quarter Linear initiatives, i.e. OKRs).
3. **Delegate** — invoke the team skill with an explicit output path and the loaded context. Don't reimplement.
4. **Augment** — do the personal filing step (here: ensure the per-date folder exists; the team skill writes directly into it).

If `OBSIDIAN_VAULT_DAILY_JOURNAL` is unset, the skill no-ops with one line of explanation. Teammates who don't use Obsidian see no behavior change.

## Activation rules

Activate when **either** is true:

1. The user explicitly invokes `/daily-obsidian` (or describes the intent: "daily brief into obsidian", "file today's daily into my vault").
2. The user invokes `/daily` AND `OBSIDIAN_VAULT_DAILY_JOURNAL` is set in the environment.

Check the env var with `printenv OBSIDIAN_VAULT_DAILY_JOURNAL` via Bash. If empty / unset:

- For `/daily-obsidian`: respond with one sentence — "Set `OBSIDIAN_VAULT_DAILY_JOURNAL` to your journal folder (e.g. `~/obsidian/<vault>/Journal`) and re-run." — and stop. Do not run `/daily` from this skill in that case.
- For `/daily` itself: this skill does nothing; let the team skill run alone.

## Writing principles (apply to every brief)

Apply the `/smart-brevity` skill for prose. One additional rule specific to this skill's OKR injection:

- **OKRs push, never parrot.** Every OKR mention closes with one concrete action today that moves it forward — not a status read-out. If health is `atRisk` or `offTrack`, flag it explicitly.

The HTML uses the `html-output` skill's `doc.html` template — logos inlined as `data:` URIs, brand fonts via `@font-face { src: local(...) }` with Google-Fonts fallback. **Single-file artifact, shareable as-is.** Every brief is self-contained — no sibling `assets/` directory, no missing-asset breakage on a recipient's machine.

## What this skill does — four phases

### Phase 1 — Detect

```bash
VAULT_JOURNAL="${OBSIDIAN_VAULT_DAILY_JOURNAL:-}"
[ -z "$VAULT_JOURNAL" ] && { echo "OBSIDIAN_VAULT_DAILY_JOURNAL not set; daily-obsidian inactive."; exit 0; }
[ -d "$VAULT_JOURNAL" ] || { echo "OBSIDIAN_VAULT_DAILY_JOURNAL=$VAULT_JOURNAL does not exist; daily-obsidian inactive."; exit 0; }
```

### Phase 2 — Load OKRs (push the quarterly agenda into the brief)

Current-quarter OKRs live in Linear as **initiatives owned by the user, status Active, whose name starts with a period prefix** like `2026 Q2:`. The skill computes that prefix from today's date — no env var, no hand-maintained list.

Compute the prefix:

```bash
YEAR="$(date +%Y)"
MONTH_NUM="$(date +%m)"
case "$MONTH_NUM" in
  01|02|03) Q=1 ;;
  04|05|06) Q=2 ;;
  07|08|09) Q=3 ;;
  10|11|12) Q=4 ;;
esac
PERIOD_PREFIX="${YEAR} Q${Q}:"   # e.g. "2026 Q2:"
```

Fetch and filter via the Linear MCP tool:

```
mcp__claude_ai_Linear__list_initiatives({ owner: "me", status: "Active" })
```

Then keep entries where `name.startsWith(PERIOD_PREFIX)`. For each surviving initiative capture: `name`, `summary`, `health`, `targetDate`, `url`. That's the OKR block.

**If zero matches:** log "No OKR initiatives match `${PERIOD_PREFIX}` for owner=me." and proceed without an OKR section. **Never synthesize fake OKRs.** A missing-OKR brief is a real signal — go set them in Linear.

### Phase 2.5 — Load recently-shipped projects (for the standup top)

Shipped workstreams are logged by the `/debrief` skill in an append-only index at
the Journal root. Surface the recent ones at the top of the standup so the brief
opens with "here's what just landed", each linking its debrief.

```bash
SHIPPED_INDEX="${OBSIDIAN_VAULT_DAILY_JOURNAL}/shipped-projects.md"
# Take the most recent 5 entries (file is newest-first; entries start with "- ").
[ -f "$SHIPPED_INDEX" ] && grep -m 5 '^- ' "$SHIPPED_INDEX"
```

If the file is absent or empty, skip the shipped block entirely — no placeholder.
Pass the captured lines to `/daily` in Phase 3. Keep the debrief links intact
(they're relative to the Journal root; the brief lives two levels deeper, so
prefix each with `../../` when rendering, or render the link text only if the
relative path is fiddly — the filename carries enough provenance).

### Phase 3 — Delegate (with OKR context + explicit output path)

Invoke the team's `/daily` skill. **Tell it to write the HTML directly to the vault** — there is no scratch step in the working repo.

The output path is:

```
$OBSIDIAN_VAULT_DAILY_JOURNAL/$YEAR/$MONTH/$DATE/$DATE-$DAYNAME-daily.html
```

Where:

| Variable | Example value | How |
|---|---|---|
| `$DATE` | `2026-05-28` | `$(date +%Y-%m-%d)` |
| `$DAYNAME` | `Thursday` | `$(date +%A)` |
| `$YEAR` | `2026` | `$(date +%Y)` |
| `$MONTH` | `05-May` | `$(date +%m-%B)` |

The per-date folder `$DATE/` is the day's container — daily brief + meeting notes + ad-hoc HTMLs all live there. The filename always carries `$DATE-$DAYNAME` so any single HTML is shareable standalone with full provenance ("that's `2026-05-28-Thursday-jochen-cfo-meeting-notes.html`").

The `/daily` skill produces a single self-contained HTML via `html-output`'s `doc.html` template. Logos + fonts are handled by the template — do not duplicate that logic here.

**Pass the OKR block as context with this instruction:**

> The following are the user's current-quarter OKRs (Linear initiatives owned by the user, status Active, period prefix `${PERIOD_PREFIX}`). **Render them as the very first section of the brief**, titled `OKRs — push these today`. For each OKR: one tight line stating it (link the name to its Linear URL), then exactly one bullet — a concrete action today that pushes it forward, drawn from today's calendar / open Linear issues / Slack threads. Flag `health: atRisk` or `offTrack` inline. Do not list OKRs without an accompanying action.
>
> OKR data:
> ```json
> { "period_prefix": "${PERIOD_PREFIX}", "okrs": [ {…initiative fields…} ] }
> ```

If Phase 2 produced zero matches, skip this paragraph entirely — `/daily` runs without an OKR section.

**Pass the shipped-projects lines (Phase 2.5) as context with this instruction:**

> The following are recently-shipped projects (newest first), each with a link to
> its debrief. **Render them as a `Recently shipped` block at the very top of the
> standup section** — a tight bullet per project: `**<Project>** (<date>) — <one-clause
> result> · [debrief](<link>)`. This opens the brief with what just landed. Skip
> the block entirely if no lines were provided.
>
> Shipped projects:
> ```
> <the `- ...` lines from Phase 2.5, verbatim>
> ```

If Phase 2.5 produced no lines, skip this paragraph — no `Recently shipped` block.

### Phase 4 — Augment (ensure folder exists; that's it)

```bash
DATE="$(date +%Y-%m-%d)"
DAYNAME="$(date +%A)"
YEAR="$(date +%Y)"
MONTH="$(date +%m-%B)"
DAY_DIR="${OBSIDIAN_VAULT_DAILY_JOURNAL}/${YEAR}/${MONTH}/${DATE}"
mkdir -p "$DAY_DIR"
# /daily writes to:  ${DAY_DIR}/${DATE}-${DAYNAME}-daily.html
```

That's the whole step. **No `.md` daily note. No wikilink insertion.** The HTML is the artifact; the per-date folder is the index.

Report back to the user: the vault path that was written + a one-sentence summary of what the brief covers.

## Idempotency

`/daily-obsidian` should be safe to re-run during the day (e.g. after the standup, when more outcomes land).

- **Overwrite is fine.** `${DATE}-${DAYNAME}-daily.html` is meant to evolve through the day. Re-runs replace it.
- **`mkdir -p` is a no-op** on an existing folder.
- **Other files in the per-date folder are untouched.** Meeting notes and ad-hoc HTMLs Jan dropped into `$DATE/` stay where they are.

### Legacy-layout migration (run once per old format you find)

The vault has been through several conventions. If you encounter any of these, normalize before adding new artifacts:

| You find | Action |
|---|---|
| HTML at month root (e.g. `2026-05-28-Thursday.html`) | Create `2026-05-28/` folder, rename file to `2026-05-28-Thursday-daily.html`, move it inside |
| Filename with `-daily-brief` suffix (e.g. `2026-05-28-Thursday-daily-brief.html`) | Rename to `2026-05-28-Thursday-daily.html` in the per-date folder |
| Filename like `2026-05-27-daily.html` (no DayName) | Compute the DayName and rename to `2026-05-27-Wednesday-daily.html` |
| Sibling `<date>-daily-assets/` directory | Inline the four logos into the matching HTML's `<img src=...>` attributes, then `rm -rf` the assets dir |
| Old wikilinks in any remaining `.md` files | Rewrite each `[[<old-name>.html]]` → `[[<new-name>.html]]`; preserve the `|HTML` display label if present |
| `.md` daily notes at month root | Move into the per-date folder unchanged. Going forward `/daily-obsidian` doesn't create new ones, but pre-existing ones stay for history. |

A one-shot Python script for the May 2026 migration is at `/tmp/restructure_may_journal.py` (used 2026-05-28). Adapt the `moves` list for subsequent months.

## Configuration

```bash
# In ~/.zshrc or equivalent — point at the Journal folder, not the vault root.
export OBSIDIAN_VAULT_DAILY_JOURNAL="$HOME/obsidian/<vault>/2 - Areas/Journal"
```

Unset to disable the extension. The team `/daily` continues to work unchanged (it just writes its default output and stops).

## Extension pattern for the team

If you want to write a similar personal layer over a team skill:

1. **Drop a SKILL.md in `~/.agents/skills/<your-skill>/`** (or in `~/dotfiles/stow/agents/.agents/skills/<your-skill>/` if you stow your dotfiles).
2. **Gate the skill on an env var** so the team skill stays the default for everyone else.
3. **Don't reimplement the team skill.** Reference it by name in your skill's instructions; delegate to it with an explicit output path when you need to redirect its writes. When the team skill changes, your layer keeps working.
4. **Be additive only.** Your skill writes new artifacts; it doesn't mutate the team skill's output.
5. **Keep the description trigger-rich.** The skill router needs to know when to activate. Mention `/your-skill` plus the natural-language phrases the user actually says.

This file is itself the template: read it back, swap "Obsidian" for "Notion" / "Slack" / "Confluence" / "private wiki", swap Phase 4 for whatever filing you want (and Phase 2 for whatever personal context block you want pushed into the brief — OKRs here, but the slot is generic), and you have your own personal extension in ~30 minutes.

## Known limitations

- **Date computed from `date(1)` in the user's local TZ.** If you run `/daily-obsidian` for yesterday's brief, override `DATE` (and `DAYNAME`) manually in the Bash blocks above.
- **Month folder naming assumes `MM-MonthName` (e.g. `05-May`).** If your vault uses a different convention, edit the `MONTH=...` line. Don't make the team skill care about this — it's a personal preference.
- **Per-date folder layout assumes one folder per calendar day.** Some teams prefer a flat month folder; either works, change Phase 3's output path and Phase 4's `mkdir -p` if you swap. Keep the `$DATE-$DAYNAME-<topic>.html` filename convention regardless — that's what makes individual files shareable standalone.
