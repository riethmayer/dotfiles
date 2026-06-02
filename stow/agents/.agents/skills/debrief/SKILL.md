---
name: debrief
description: >-
  Write a shipped-project debrief — a self-contained, brand-styled HTML artifact
  that explains what shipped, the non-obvious root cause behind any bug or
  decision (verified, not assumed), the learning, and the wider impact. Files it
  into the Obsidian vault's per-date journal folder, links it directly into
  today's daily brief, and adds it to the recently-shipped index. Every run also
  writes a forward-looking handoff for the next session and copies it to the
  clipboard so you can immediately start a clean session. Use when the user says
  "/debrief", "debrief this", "write a debrief", "ship debrief", "project
  debrief", "post-mortem this", "do a debrief on the X work", or has just landed
  a workstream / merged a set of PRs and wants the wrap-up captured. Also trigger
  after a /ship or a "we just shipped X" moment when the user wants the story
  written down. Distinct from /brief (a forward-looking decision brief for
  leadership) and /handoff (transfer in-flight work to another agent) — /debrief
  is the retrospective on work that already shipped. Only fully activates when
  OBSIDIAN_VAULT_DAILY_JOURNAL is set.
metadata:
  type: personal-layer
---

# Debrief — shipped-project retrospective

A debrief turns a just-shipped workstream into a tight, shareable artifact that a
busy partner can read in under a minute and learn from. It is the opposite of a
status dump: lead with the outcome, prove the surprising part, state the lesson,
name who else it affects.

This skill exists because the *interesting* content of shipped work is almost
never "we merged the PRs." It's the thing that wasn't obvious — the bug whose
cause was misdiagnosed, the decision whose reasoning isn't visible in the diff.
A debrief captures that so the next person doesn't relearn it the hard way.

## Activation gate

This is a personal layer over the Obsidian journal, like `daily-obsidian`. Check
the env var first:

```bash
VAULT_JOURNAL="${OBSIDIAN_VAULT_DAILY_JOURNAL:-}"
[ -z "$VAULT_JOURNAL" ] && { echo "OBSIDIAN_VAULT_DAILY_JOURNAL not set; /debrief writes to the repo instead (docs/debriefs/)."; }
[ -n "$VAULT_JOURNAL" ] && [ ! -d "$VAULT_JOURNAL" ] && { echo "OBSIDIAN_VAULT_DAILY_JOURNAL=$VAULT_JOURNAL does not exist."; }
```

If the var is set, write to the vault (default). If unset, fall back to
`docs/debriefs/<project>.html` in the current repo and skip the index step — tell
the user that's what you did.

## The eight learnings this skill encodes

These are non-negotiable defaults distilled from real debriefs. Each one is here
because skipping it produced a worse artifact:

1. **Verify the root cause — never restate the assumption.** The first
   explanation is often wrong. The canonical case: a slack-bot health probe
   404'd and was blamed on a framework bug; it was actually a documented Cloud
   Run reserved-path rule. If a debrief names a cause, that cause must be
   *confirmed* — by probing the live system, reading logs, AND searching for the
   documented behavior (WebSearch / vendor docs). Cite the source. A debrief that
   ships a plausible-but-wrong cause is worse than no debrief.
2. **Lead with the outcome.** First sentence states what shipped and the result —
   not the journey. The headline is the takeaway, not the topic ("slack-bot's 404
   was a reserved Cloud Run path" beats "slack-bot health investigation").
3. **Apply Smart Brevity.** One idea per sentence, cut filler, bold the 1–3
   load-bearing words per block. If the `smart-brevity` skill is available, run
   the prose through it. (See its rules.)
4. **Make the Learning explicit.** A labelled **The learning:** block — what
   should we do differently next time, stated as a rule, not a war story.
5. **Make the Wider impact explicit.** A labelled **Wider impact:** block — who
   or what else this affects (other services, other teams, a convention to adopt).
   This is what turns a local fix into institutional knowledge.
6. **Link every PR / issue to its source.** `#3779` → a GitHub link
   (`https://github.com/<owner>/<repo>/pull/N`). Same for Linear issues, Sentry
   issues — any ID with a canonical URL. The reader jumps straight there.
   (See `feedback_link_prs_to_github` in memory.)
7. **Ship a self-contained, brand-styled HTML artifact** filed where it's
   findable. Make it visible two ways: link it directly into today's daily brief
   (so it shows up *now*, not only when the daily is next regenerated), and
   register it in the recently-shipped index (so future dailies keep linking it).
   The index alone isn't enough: a debrief written after the daily was built
   would otherwise never appear in that day's brief.
8. **End with a handoff for the next session.** Shipping one thing is the moment
   you have the most context about what comes next. Capture it as a
   forward-looking handoff and put it on the clipboard, so starting a clean
   session is a paste away. The debrief looks back; the handoff it leaves looks
   forward.

## Workflow

### 1. Gather what shipped

Pull the concrete facts. Don't ask the user for what you can read:

- PRs / commits: `git log <base>..HEAD --oneline`, `gh pr list --state merged
  --search "..."`, or the PR numbers the user names.
- What each PR did + its outcome (merged / applied / deployed / verified).
- The production result — if the work is verifiable in prod (an endpoint, a
  metric, a deploy), **probe it** and quote the real signal, not a claim.

### 2. Find the non-obvious thing — and verify it

Every shipped workstream has one. A misdiagnosed bug, a counterintuitive
decision, a constraint that surprised you. This is the spine of the debrief.

**Verify it before you write it** (learning #1):

- Reproduce / probe the live behavior (`curl`, logs, metrics).
- Search for the documented cause — `WebSearch`, vendor docs, the relevant
  `context7` library docs. A 30-second probe + one doc lookup beats a confident
  guess.
- If you can't confirm a cause, say so explicitly ("cause unconfirmed — leading
  hypothesis is X") rather than asserting.

### 3. Write the debrief — structure

Use this skeleton. Each section opens with its conclusion (Smart Brevity rule 1):

```
# <Outcome-led title — the takeaway, not the topic>

<Lead: what shipped + the result, in 1–2 sentences. The single most
important thing, first.>

## What shipped
<Tight table or list: PR (linked) · what · outcome. No journey, just facts.>

## <The surprising part — headline states the finding>
<The verified root cause / decision. Lead with the answer.>
**The proof:** <the evidence that confirms it — probe results, log absence,
the doc that documents it (linked).>

**The learning:** <one rule for next time.>

**Wider impact:** <who/what else this affects; the convention to adopt.>

## <Optional: QA / verification, coverage, open follow-ups>
```

Not every debrief needs every section — a clean feature ship may have no
"surprising part." But if there *was* a misdiagnosis or a non-obvious decision,
that section is the most valuable part of the document. Don't bury it.

### 4. Render the HTML artifact

Produce a **single self-contained file** — logos and fonts inlined, no sibling
assets dir (so it's shareable as-is). Two ways, in order of preference:

1. **Clone the chrome from the most recent daily/debrief HTML** in the vault and
   swap the body. This inherits the already-inlined Earlybird logos + `@font-face
   local()` fonts + sidebar/dark-mode/keyboard JS for free:
   ```bash
   find "$VAULT_JOURNAL" -name '*-daily.html' -o -name '*-debrief.html' | sort | tail -1
   ```
   Keep everything up to `<div class="container">` and from `<footer>` onward;
   replace only the `<header>` + `<section>` blocks. The sidebar auto-builds from
   `<h2 class="section-title">` elements. Splice with a short Python script
   (keep head lines + new body + tail lines) rather than hand-editing 200 KB of
   base64.
2. If no prior artifact exists, use the `html-output` skill's `doc.html` template.

**Table styling:** the base `doc.html` template ships *no* screen table CSS, so a
bare `<table>` renders as raw columns. Inject the brand table style before
`</style>` — see `references/table-style.css`. Always add a `<colgroup>` so the
first (ID) column stays narrow and the last column doesn't sprawl.

Filename + location (per-date folder, matching `daily-obsidian`):

```
$VAULT_JOURNAL/$(date +%Y)/$(date +%m-%B)/$(date +%Y-%m-%d)/$(date +%Y-%m-%d)-$(date +%A)-<project-slug>-debrief.html
```

`<project-slug>` is kebab-case (e.g. `canonical-tier-1-observability`). Create the
per-date folder with `mkdir -p` (idempotent). Re-running overwrites the same file.

After writing, verify it parses (`python3 -c "import html.parser;
html.parser.HTMLParser().feed(open(p).read())"`) and `open` it.

### 5. Register it in the recently-shipped index

Append one line to `$VAULT_JOURNAL/recently-shipped.md` (create it if absent —
see `references/recently-shipped-template.md`). Newest entries go at the top so
the daily brief shows the most recent first:

```markdown
- 2026-05-29 · **Canonical Tier-1 Observability** — [debrief](2026/05-May/2026-05-29/2026-05-29-Friday-canonical-tier-1-observability-debrief.html) · 5/6 Tier-1 apps probed
```

The link path is relative to the Journal root (where `recently-shipped.md` lives).
The `daily-obsidian` skill reads this file and renders the recent entries at the
top of the standup section. Keep the one-line summary to a single clause — the
debrief itself holds the detail.

### 6. Link it into today's daily brief

Registering in the index (step 5) only surfaces the debrief when the daily is
*next regenerated*. If today's daily already exists, the debrief you just wrote
won't show up in it - which is the common case when you debrief after the
morning brief. So link it in directly with the bundled script. It owns a
marker-delimited `Debriefs filed today` block: it creates that section on the
first debrief of the day and prepends to it on later ones (newest first, deduped
on re-run):

```bash
DAILY="$VAULT_JOURNAL/$(date +%Y)/$(date +%m-%B)/$(date +%Y-%m-%d)/$(date +%Y-%m-%d)-$(date +%A)-daily.html"
python3 ~/.claude/skills/debrief/scripts/link_into_daily.py \
  --daily "$DAILY" \
  --href "$(date +%Y-%m-%d)-$(date +%A)-<project-slug>-debrief.html" \
  --title "<project title>" \
  --result "<one-clause outcome>" \
  --date "$(date +%Y-%m-%d)"
```

`--href` is just the debrief filename - the daily lives in the same per-date
folder, so a bare filename resolves. The script is non-fatal: if today's daily
doesn't exist yet it says so and exits clean, and the index (step 5) still feeds
the daily whenever it's next built. The daily's sidebar auto-builds from the
section's `<h2>`, so the new block lands in nav for free.

### 7. Write the next-session handoff and copy it

Shipping is the high-context moment to capture what comes next, so every debrief
ends by leaving a handoff for a clean restart. Build it using the `/handoff`
skill's structure (Objective, State of play, Relevant artifacts, Next steps,
Suggested skills, Open questions, Gotchas - see its `SKILL.md`), but bias every
section toward *what to do after this ship*: the debrief's open follow-ups, the
next slice, the branch / PR state. Draw "what's next" from local state - branch,
open PRs, worktree, TODOs, this conversation - not from Linear unprompted.

File it beside the debrief, same naming:

```
$VAULT_JOURNAL/$(date +%Y)/$(date +%m-%B)/$(date +%Y-%m-%d)/$(date +%Y-%m-%d)-$(date +%A)-<project-slug>-handoff.md
```

Then copy it so a fresh session is one paste away - raw markdown, no code fences:

```bash
pbcopy < "$VAULT_JOURNAL/$(date +%Y)/$(date +%m-%B)/$(date +%Y-%m-%d)/$(date +%Y-%m-%d)-$(date +%A)-<project-slug>-handoff.md"
```

macOS `pbcopy`; the clipboard gets the file's raw content, so don't wrap it in
fences. If `OBSIDIAN_VAULT_DAILY_JOURNAL` is unset, skip the vault file: write the
handoff to `$TMPDIR`/`/tmp` (the `/handoff` default) and still `pbcopy` it - the
clipboard step never depends on the vault.

### 8. Report back

One tight block:
- the debrief vault path + that the browser opened
- that it's linked into today's daily (or that the daily didn't exist yet, so
  only the index was updated)
- that it's in the recently-shipped index
- that the next-session handoff is filed AND on the clipboard, ready to paste
  into a clean session

## Reference files

- `scripts/link_into_daily.py` - injects the direct debrief link into today's daily HTML (step 6). Idempotent, non-fatal if no daily exists yet.
- `references/table-style.css` - brand table CSS to inject into cloned chrome.
- `references/recently-shipped-template.md` - the index file's initial content.
