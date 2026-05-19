---
name: daily-obsidian
description: Personal extension of the team's /daily skill — drops the polished HTML brief into an Obsidian vault's daily-note folder and adds a wikilink from the markdown daily note. Use when the user says "/daily-obsidian", "daily into obsidian", or asks to file the daily brief into their vault. Only activates when the OBSIDIAN_VAULT_DAILY_JOURNAL environment variable is set.
---

# Daily — Obsidian extension

A personal extension of the team's `/daily` skill that files the polished HTML brief next to the markdown daily note in an Obsidian vault — so the searchable notes and the shareable brief live in one place.

## Why this skill exists — and why it's a template

The team owns `/daily`. Forking it for personal preferences pollutes the team skill and creates merge churn. The cleaner pattern: **leave the team skill alone, write a thin personal skill that calls it and post-processes the output.**

This skill is a worked example of that pattern. Teammates can copy this folder, rename it, swap the post-processing step, and end up with their own personal layer on top of `/daily` — no fork required.

The whole pattern: **detect → delegate → augment.**

1. **Detect** — read an env var that the personal user (not the team) sets.
2. **Delegate** — invoke the team skill verbatim. Don't reimplement.
3. **Augment** — do the personal step (in this case, file into Obsidian).

If `OBSIDIAN_VAULT_DAILY_JOURNAL` is unset, the skill no-ops with one line of explanation. Teammates who don't use Obsidian see no behavior change.

## Activation rules

Activate when **either** is true:

1. The user explicitly invokes `/daily-obsidian` (or describes the intent: "daily brief into obsidian", "file today's daily into my vault").
2. The user invokes `/daily` AND `OBSIDIAN_VAULT_DAILY_JOURNAL` is set in the environment.

Check the env var with `printenv OBSIDIAN_VAULT_DAILY_JOURNAL` via Bash. If empty / unset:

- For `/daily-obsidian`: respond with one sentence — "Set `OBSIDIAN_VAULT_DAILY_JOURNAL` to your journal folder (e.g. `~/obsidian/<vault>/Journal`) and re-run." — and stop. Do not run `/daily` from this skill in that case.
- For `/daily` itself: this skill does nothing; let the team skill run alone.

## What this skill does — three phases

### Phase 1 — Detect

```bash
VAULT_JOURNAL="${OBSIDIAN_VAULT_DAILY_JOURNAL:-}"
[ -z "$VAULT_JOURNAL" ] && { echo "OBSIDIAN_VAULT_DAILY_JOURNAL not set; daily-obsidian inactive."; exit 0; }
[ -d "$VAULT_JOURNAL" ] || { echo "OBSIDIAN_VAULT_DAILY_JOURNAL=$VAULT_JOURNAL does not exist; daily-obsidian inactive."; exit 0; }
```

### Phase 2 — Delegate

Invoke the team's `/daily` skill. Let it run end-to-end and write the HTML wherever it normally writes (today: `briefs/YYYY-MM-DD-daily/daily.html` in the working repo, with assets in `briefs/YYYY-MM-DD-daily/assets/`).

Do not duplicate the team skill's logic here. The whole point is that this layer stays thin.

### Phase 3 — Augment (file into the vault)

After `/daily` has produced `briefs/<date>-daily/daily.html`:

1. Compute the target path inside the vault. Given today is `YYYY-MM-DD-DayName` (e.g. `2026-05-19-Tuesday`), and `OBSIDIAN_VAULT_DAILY_JOURNAL` points at the journal root, the target attachments directory is:

   ```
   $OBSIDIAN_VAULT_DAILY_JOURNAL/YYYY/MM-MonthName/attachments/YYYY-MM-DD-daily.html
   ```

   Mirror the existing `YYYY/MM-MonthName/` layout — the user already organizes daily `.md` notes that way; the HTML sibling stays alongside.

2. Copy the HTML + the entire `assets/` folder (logos) into the vault:

   ```bash
   DATE="$(date +%Y-%m-%d)"
   DAYNAME="$(date +%A)"
   YEAR="$(date +%Y)"
   MONTH="$(date +%m-%B)"   # e.g. 05-May
   SRC_DIR="briefs/${DATE}-daily"
   VAULT_DIR="${OBSIDIAN_VAULT_DAILY_JOURNAL}/${YEAR}/${MONTH}/attachments"
   mkdir -p "${VAULT_DIR}/${DATE}-daily-assets"
   cp "${SRC_DIR}/daily.html" "${VAULT_DIR}/${DATE}-daily.html"
   cp -R "${SRC_DIR}/assets/." "${VAULT_DIR}/${DATE}-daily-assets/"
   ```

   Then rewrite the HTML's logo paths so they resolve inside the vault:

   ```bash
   sed -i '' "s|./assets/|./${DATE}-daily-assets/|g" "${VAULT_DIR}/${DATE}-daily.html"
   ```

3. Insert a wikilink at the top of the daily note's `## Morning Standup` section, **above** `### Intentions`. Format:

   ```markdown
   📎 Polished brief: [[attachments/YYYY-MM-DD-daily.html|HTML]]
   ```

   The Edit tool is the right tool — find `## Morning Standup\n` and append the link. Don't duplicate the line if it's already there (idempotent re-runs).

4. Report back to the user: vault target path + one-sentence confirmation.

## Idempotency

`/daily-obsidian` should be safe to re-run during the day (e.g. after the standup, when more outcomes land). Specifically:

- Overwriting `${DATE}-daily.html` is fine — that's the whole point; the brief evolves.
- Re-copying the `assets/` folder is fine.
- The wikilink insertion check: grep the daily note for `${DATE}-daily.html` before inserting. If present, skip.
- The team `/daily` skill already handles idempotent appends to `### Done` — let it.

## Configuration

```bash
# In ~/.zshrc or equivalent — point at the Journal folder, not the vault root.
export OBSIDIAN_VAULT_DAILY_JOURNAL="$HOME/obsidian/<vault>/2 - Areas/Journal"
```

Unset to disable the extension. The team `/daily` continues to work unchanged.

## Extension pattern for the team

If you want to write a similar personal layer over a team skill:

1. **Drop a SKILL.md in `~/.agents/skills/<your-skill>/`** (or in `~/dotfiles/stow/agents/.agents/skills/<your-skill>/` if you stow your dotfiles).
2. **Gate the skill on an env var** so the team skill stays the default for everyone else.
3. **Don't reimplement the team skill.** Reference it by name in your skill's instructions; delegate to it. When the team skill changes, your layer keeps working.
4. **Be additive only.** Your skill writes new artifacts; it doesn't mutate the team skill's output (beyond cosmetic path rewrites like the logo `sed` above).
5. **Keep the description trigger-rich.** The skill router needs to know when to activate. Mention `/your-skill` plus the natural-language phrases the user actually says.

This file is itself the template: read it back, swap "Obsidian" for "Notion" / "Slack" / "Confluence" / "private wiki", swap Phase 3 for whatever filing you want, and you have your own personal extension in ~30 minutes.

## Known limitations

- **Date computed from `date(1)` in the user's local TZ.** If you run `/daily-obsidian` for yesterday's brief, override `DATE` manually in the Bash block above.
- **Month folder naming assumes `MM-MonthName` (e.g. `05-May`).** If your vault uses a different convention, edit the `MONTH=...` line. Don't make the team skill care about this — it's a personal preference.
- **No conflict resolution on the wikilink.** If you have two `attachments/` link styles (relative vs Obsidian-resolved), pick one and stick with it; the skill writes the `[[attachments/...]]` form which Obsidian resolves vault-locally.
