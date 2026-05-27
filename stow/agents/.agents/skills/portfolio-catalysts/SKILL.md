---
name: portfolio-catalysts
description: Surfaces concrete Portfolio Excellence catalysts (workshops, 1-on-1 deal reviews, advisor sessions, tactical playbooks) that Earlybird can offer a specific founder or portfolio company at first contact. Reads the canonical catalogue at `catalogue.md` and matches against a target company's sub-sector, stage, and current situation. Used as Block 7 of `/deep-dive` and as a standalone skill when an investor asks "what can we offer this founder right now?" or a portfolio company asks "what's available for me?". Use whenever the user mentions catalysts, workshops, advisor sessions, Portfolio Excellence offerings, or asks what value-adds Earlybird can bring to a founder.
metadata:
  workspace: eb
  visibility: workspace
  shape: leaf
  used-by-skills:
    - deep-dive
---

# /portfolio-catalysts

Match a target company / founder against the Earlybird Portfolio Excellence catalogue and return the most relevant catalysts (top 3 by default) with one-sentence reasoning each. The catalogue is the structured `catalogue.md` file in this skill folder — currently a markdown file maintained by Portfolio Excellence; later possibly a BigQuery table or Notion DB export. The skill abstracts over the storage layer.

## When to invoke

- The user is running `/deep-dive` and Block 7 (Catalysts) is firing.
- An investor asks "what can we offer [founder/company]?" or "what catalysts do we have for [domain]?".
- A portfolio company asks "what's available for me right now?".
- The user mentions Portfolio Excellence, advisor sessions, workshops, or value-adds for founders.

## Inputs

**Required (one of):**
- A target company described by `{ name, sub_sector, stage, situation }` (typical when called from `/deep-dive`).
- A topic / domain query ("anything on PLG → sales?", "any community workshops for B2C?").

**Helpful:**
- `affinity_org_id` — to surface "we've already offered X to this company before".
- Specific founder pain or current situation (one sentence: "they're stuck on first-10-customer hand-off to design partners").

## Output

By default: top 3 catalysts ranked by relevance, each with:
- Catalyst name + affiliation.
- Topic (the specific workshop or session).
- One-sentence "why this fits this company".
- Format (workshop / 1-on-1 / small-group / playbook).
- Stage band (Pre-seed / Seed / Series A — must match the target's stage).
- Pointer to the catalogue entry for full description.

If fewer than 3 strong matches exist, return what's there and flag the gap — "no strong matches in catalogue; consider whether Portfolio Excellence should expand coverage for sub-sector X". The flag is part of the value: thin runs are forcing functions to enrich the catalogue.

## Matching logic

The catalogue is small (currently 17 topics × 3 catalysts). A direct read + LLM match works well at this size; no embedding index needed for v0.

**Match scoring** (loose, qualitative — LLM-judged):

1. **Stage match (hard filter)** — if the target's stage isn't in the topic's `stages`, exclude. A Series B company doesn't get a Pre-seed workshop suggestion.
2. **Domain match** — does the catalyst's `catalyst_domain` (Growth / Sales / GTM Leadership / etc.) fit the company's current need?
3. **Topic match** — semantic similarity between the company's described situation and the topic title + description.
4. **Tag overlap** — derived `tags` field gives a fast keyword boost.
5. **Portco hint bonus** — if the catalogue entry's `suggested_eb8_portcos` or `suggested_eb7_portcos` already names the target (or a close analog), boost the score. The Portfolio Excellence team curated those hints with intent.

**Output format (when called from `/deep-dive`):**

Return `rendered` (HTML for Block 7) + `evidence` pack per the orchestrator-skill contract. See `shared/writing-orchestrator-skills/SKILL.md` for the schema.

**Example rendered HTML block:**

```html
<div class="catalysts">
  <div class="catalyst">
    <div class="catalyst-name">Tilen — Head of Content & Community at Synthesia</div>
    <div class="catalyst-topic">Going viral: repeatable frameworks for distribution</div>
    <p class="catalyst-why"><em>Why this fits:</em> Plana is at Seed and building B2B distribution from a founder-led brand. Tilen's worked example with Synthesia maps directly onto Marie's situation.</p>
    <div class="catalyst-meta">Workshop · Seed · Pre-seed / Seed / Series A</div>
  </div>
  ...
</div>
```

## When the catalogue has gaps

If matching produces fewer than 3 strong candidates, the block still ships but adds a footer:

> _Catalyst-catalogue gap detected:_ this company would benefit from depth in [area X / Y] but the current catalogue has no matches. Surfacing to Portfolio Excellence for consideration.

Two reasons this matters:

1. **Honesty.** A weak match dressed up as a strong one is worse than no match. The investor opens the brief expecting concrete value-adds; padded matches erode trust.
2. **Forcing function.** Every gap surfaced is a candidate for the Portfolio Excellence team to recruit a new catalyst for. The skill becomes the demand signal that drives catalogue growth.

## v0 storage — markdown file, DB later

The catalogue today lives in `catalogue.md` (this folder). The skill reads it directly — no parser, just LLM ingestion. This is the right v0 because:

- The catalogue is small (~20 topics).
- Portfolio Excellence can edit it without engineering.
- Schema iteration is cheap (just edit the file).
- PRs to the skills repo give us versioning + review.

**When to migrate:**

- The catalogue grows past ~100 topics (LLM ingestion becomes lossy).
- Multiple non-skill consumers appear (TTM dashboard, Notion view, etc.).
- The maintainer wants a non-PR editing workflow (Notion, Airtable, etc.).

**Migration target:** likely a BigQuery table mirrored from a Portfolio Excellence-owned Notion DB, with a scheduled export back into `catalogue.md` to preserve the human-readable form for review. When migrating, update this SKILL.md's "Matching logic" section to read from the new source — the rest of the contract stays stable.

## Calibration loop

Like every block of `/deep-dive`, this skill should accept thumbs feedback from the investor after the call:

- 👍 / 👎 / "wrong match" per catalyst suggestion
- Optional comment

That feedback feeds the eval suite (and signals catalogue gaps when "wrong match" is high for a sub-sector). Wire via PostHog LLMA per the `posthog:llma-cc-*` pattern.

## Files in this skill

- `SKILL.md` — this file.
- `catalogue.md` — the canonical v0 catalogue (17 topics × 3 catalysts as of 2026-05-22).

## Related skills

- `eb/ic/deep-dive/` — primary consumer (Block 7).
- `shared/writing-orchestrator-skills/` — explains the rendered + evidence-pack return shape this skill uses when called from an orchestrator.
- Future `eb/portfolio-excellence/*` — when that sub-team takes ownership of the catalogue, this skill may move under it.
