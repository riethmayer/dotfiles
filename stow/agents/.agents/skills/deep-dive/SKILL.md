---
name: deep-dive
description: Produces an IC-grade pre-call brief on a company or founder in roughly 20 minutes — pulls the EagleEye data warehouse (Affinity + Harmonic + Dealroom + Crunchbase + LinkedIn enrichment via BigQuery), applies the Earlybird investment-thesis taxonomy, surfaces comparable deals from our own history including historical underperformers, identifies catalysts Portfolio Excellence can offer the founder, and ends with the ten questions worth asking on the call. Every block self-scores against an explicit rubric, every claim cites its source, and the whole brief is designed against EU AI Act + GDPR obligations. Use whenever an investor wants a deep dive on a founder or company — also trigger on "/deep-dive", "prep me for the [company] call", "what do we know about [founder]", "I'm meeting [company] tomorrow", "give me the read on [company]", or whenever the user pastes a LinkedIn company URL or website URL in the context of pre-call preparation.
metadata:
  version: 0.1.0
  workspace: eb
  visibility: workspace
  executable: false
---

# /deep-dive — pre-call brief in 20 minutes

This skill produces an HTML artifact an investor can open on their phone two minutes before a founder call and walk in prepared. The artifact ends with ten ranked questions tied to specific open points in the body of the brief. It is not a recommendation — it is structured evidence + the questions a human partner should still ask.

> **Anti-oracle posture.** The deep-dive informs a human decision; it does not make one. Block 8 ends in questions, not a verdict. The IC memo skill (`/ic-memo`, downstream) requires a partner-supplied stance before generating; it does not auto-fill from the deep-dive. This is both a product choice and an EU AI Act / GDPR Article 22 hygiene principle.

## When to invoke

- User pastes a LinkedIn company URL or website URL and asks for a brief, prep, or read.
- User says "/deep-dive", "prep me for [company]", "what do we know about [founder]", "I'm meeting [company] tomorrow".
- User describes a founder call coming up and asks for context.

Don't use this skill for: deal-flow inbox triage (that's `/daily`), writing the IC memo (that's `/ic-memo`, downstream), or technical due diligence after IC (that's `/tdd-bundle`).

## Inputs

**Required:** a **LinkedIn company URL** _or_ a **website URL**. Either resolves to the rest via the first SQL query. Company name alone is too ambiguous — refuse and ask for a URL.

**Helpful, but optional:**
- The source of the deal (warm intro from X, cold inbound, Affinity referral, conference, Harmonic signal).
- The round being raised, if known.
- Time to the call (30-min screening vs 90-min partner meeting — shapes depth budget).

**Pastes are welcome:** the founder's deck, an email thread, a back-channel note. The skill ingests them into the evidence pool.

## Output

A single self-contained HTML brief, rendered via the `html-output` skill conventions (Earlybird brand shell, sidebar nav, light/dark, keyboard layer). Saved alongside any future invocation under a stable URL so the same brief can be re-opened, forwarded, or referenced from `/call-debrief` later.

## The eight blocks

The brief renders these in order. Each block is MCP-gated: if its required tools aren't configured for the user, the block is omitted from the body and surfaced in a "Skipped (MCP not configured)" footer. Same pattern as `/daily`.

| # | Block                       | What it produces                                                                             |
|---|----------------------------|----------------------------------------------------------------------------------------------|
| 1 | **Snapshot**                | One paragraph + firmographic table. What they do, who they sell to, why now, HQ, stage, headcount band. |
| 2 | **Thesis fit**              | Earlybird taxonomy classification, our active stance for the sub-sector, the coverage partner, prior touch in Affinity. |
| 3 | **Founder read**            | Founder narrative + the founder-score widget (see `references/founder-score.md`), track record, prior interactions. |
| 4 | **Market & competition**    | TAM/SAM/SOM triangulation, direct/indirect/adjacent/substitute, **historical-underperformer analysis** (2–3 dead companies in this sub-sector and what advantage they lacked), explicit differentiation hypothesis. |
| 5 | **Comparable deals**        | What Earlybird has seen in this sub-sector in the last 18 months, with status and verdict notes. |
| 6 | **Risk + tripwire scan**    | Cross-source disagreements as questions, sub-sector tripwires from the thesis app, failure-mode patterns from Block 4. |
| 7 | **Catalysts we can offer**  | Three specific value-adds from the Portfolio Excellence catalogue. Reads from `eb/ic/portfolio-catalysts/catalogue.md`. |
| 8 | **Questions for the call**  | Ten ranked questions, each tied to an open point in Blocks 1–6. Top three boxed for the "if the call shortens" case. |

## How the blocks compose — the orchestration model

The eight blocks aren't an unordered set. They form a dependency DAG with two natural fan-out points. **Run them as follows; this is non-negotiable for context-budget reasons.** See `shared/writing-orchestrator-skills/SKILL.md` for the general pattern.

```
ID resolution                       (caller, sequential)
      ↓
Block 2: Thesis fit                 (caller, cheap) — emits sub_sector_slug
      ↓
─── parallel fan-out (one message, 4 Task calls) ───
 Block 1: Snapshot                  (subagent, JSON-heavy)
 Block 3: Founder read              (subagent, founder_deep_dive prose)
 Block 4: Market + competition      (subagent, heaviest)
 Block 5: Comparable deals          (subagent, Affinity rows)
─── join ───
      ↓
─── parallel fan-out (one message, 2 Task calls) ───
 Block 6: Risk + tripwires          (caller — synthesises evidence packs)
 Block 7: Catalysts                 (subagent)
─── join ───
      ↓
Block 8: Questions for the call     (caller — synthesises across everything)
```

**Three rules:**

1. **Each subagent gets only what it needs** — the LinkedIn URL, resolved IDs, `sub_sector_slug`, the block-specific rubric, the return shape. Not the user's full prompt or prior block outputs.
2. **Each subagent returns rendered + evidence pack.** `rendered`: HTML for the block. `evidence`: small JSON with `citations[]`, `key_claims[]`, `flags[]`, `ids[]`. The caller stitches rendered into the brief; Blocks 6 and 8 consume evidence packs, never the rendered HTML.
3. **Block 6 and Block 8 stay in the caller** because they synthesise across blocks. Caller context stays under ~30k tokens for the whole run.

## ID resolution + propagation

The very first SQL query, before any block runs, takes the LinkedIn or website URL and resolves every internal identifier we have for this company. The brief carries these IDs forward in an inline JSON header so any follow-up invocation skips the resolution step.

IDs to resolve and propagate:

| Identifier              | Source                                       | Used by                                  |
|------------------------|----------------------------------------------|------------------------------------------|
| `affinity_org_id`       | Affinity organisations table                 | All CRM writes (`update_deal`, notes)    |
| `affinity_list_entry_id`| Affinity list-entries (per round)            | Round-specific writes                    |
| `harmonic_urn`          | `gold.harmonic_companies_act`                | Similar-companies, PII reveal             |
| `dealroom_company_id`   | `gold.dealroom_companies_act`                | Funding + rounds (source of record)        |
| `linkedin_company_url`  | Echoed or resolved from website              | Founder lookups                           |
| `founder_linkedin_urls[]`| LinkedIn enrichment + Affinity person table | `founder_deep_dive`, `founder_score`      |
| `thesis_node_slug`      | Investment-thesis classifier (Block 2)       | Sub-sector filters, eval labelling        |

Embed as an inline JSON block in the rendered HTML header (machine-readable, invisible to readers) plus a visible "Identifiers" line under the cover meta for quick copy.

## Grounded in the EagleEye warehouse — start with SQL, not search

The MCP surface (`mcp__claude_ai_EagleEye__sql_*`) is the primary data source. Every block starts with `sql_discover_tables` → `sql_get_table_schema` → `sql_query` on the curated `gold` layer before reaching for the web. This inverts the search-first pattern most research skills default to.

**The three enrichment tables that appear in nearly every deep-dive:**

| Table                              | Source     | What it provides                                                              |
|-----------------------------------|------------|-------------------------------------------------------------------------------|
| `gold.harmonic_companies_act`     | Harmonic   | Sector, customer type, country, headcount, tags + highlights (Harmonic's analyst layer) |
| `gold.dealroom_companies_act` (+ `gold.dealroom_*`) | Dealroom | Industry + sub-industries, technologies, client focus, employees_latest, HQ country — **and funding / rounds: this is the funding source of record** |
| `gold.linkedin_organisation_act`  | LinkedIn   | Headcount, industry, country, short description                              |

> ⛔ **Do NOT query Crunchbase tables (`gold.crunchbase_*`).** The Crunchbase licence is winding down and that data must be deleted — **use Dealroom for funding / rounds**, not Crunchbase. (Directive 2026-05-26.)

**Cross-source validation is the moat.** When sources agree, ship confidently. When they disagree (e.g. LinkedIn 18 / Harmonic 47 / Dealroom 31 employees), surface the disagreement as a Block 6 question — don't average it away.

**Pre-baked LLM tools the skill USES, doesn't re-implement:**
- `founder_deep_dive(linkedin_url)` — Block 3 wraps this directly.
- `founder_score(linkedin_url)` — Block 3 surfaces the score with the breakdown widget.
- `my_morning_briefing()` — Block 5 can lean on this for "what does this partner already have in flight that's similar?"

**Affinity write surface for the footer CTA:** `add_deal` (new), `update_deal` (existing, surfaces `disagreements[]`), `add_note_to_deal` (attach the brief as a note).

**Deal semantics — load-bearing:** treat each row in Affinity deals as **one financing round for one company, not one company**. A company appears multiple times across rounds. When answering company-level questions, group by company identifier; preserve stage/round/status/date fields so distinct rounds are not collapsed. (See `~/code/skills/eb/ic/affinity-read/SKILL.md` if and when that primitive lands; this skill internally applies the same rule.)

## Founder-centric / stealth entry path

When the input is a **stealth founder** (a LinkedIn person URL with no resolvable company — the common output of `/find` stealth sourcing), the company-first ID-resolution above does not apply. Use this path instead:

1. **Entry table is `gold.people_signal_log`, keyed by `linkedin_endpoint`** — not the company tables. One row carries `experience_json`, `education_json`, `score_explanation`, `unicorn_score` + `unicorn_score_explanation`, and the unicorn flags, in a ~200 MB scan. **Do not scan `gold.harmonic_jobs_log` (≈23 GB, unclustered) or join `gold.harmonic_people_act` for this** — both blow the 1 GB cap. Always `sql_estimate` first.
2. **The warehouse cannot bridge a stealth person to their company.** `people_signal_log.company_name` is often just `"Stealth"` with `company_linkedin_endpoint = NULL`. So the canonical flow is: signal → **web de-anonymise the company name** (Perplexity / search) → **re-query `gold.company_entity_resolution` by `website_domain`** → Dealroom for funding. The web step is **not optional** for stealth founders — pure-warehouse stalls at "ex-BigLab person at some unnamed stealth co."
3. **Prior touch uses `gold.people_signal_affinity_check`** (keyed by `linkedin_endpoint`), not the company Affinity lookup. It surfaces the common failure mode: *logged but unworked, on the wrong list, under the "Stealth" placeholder name.* Report that explicitly.
4. **Always surface signal age.** `signal_dt` is an as-of date. Treat any signal older than ~3 months as **stale and re-qualify** — the company may have raised since (it often has). Make staleness a first-class line in the brief, not a footnote.
5. **`founder_score` fallback.** If the `founder_score` MCP tool errors or returns nothing, fall back to `people_signal_log.unicorn_score` + `unicorn_score_explanation` for the Block 3 widget (label it "unicorn-signal score"), and the Evertrace/Harmonic `score` + `score_explanation` for the headline signal score.

### Known warehouse gaps (roadmap, not skill-fixable)

- **Person↔company bridge is missing.** We can hold *both* a stealth person-signal *and* the resolved funded company and never link them. The fix is a new gold model (e.g. `gold.stealth_signal_company_resolution`) that re-links a signal to its `company_entity_resolution` row once it de-anonymises. Until it lands, do step 2 manually.
- **`harmonic_jobs_log` / `linkedin_jobs_hist` are unclustered** → company- and person-filters full-scan (~23 GB). Real fix: cluster on company key + `linkedin_endpoint`. Until then, never use them for alumni discovery in a deep-dive.
- **Triage sector mis-tags research-tooling founders as "AI Apps"** — treat the signal's sector as a routing artefact, re-derive the real sub-sector in Block 2.

## Rubrics + self-correction

Every block self-scores against an explicit rubric and surfaces the score in the rendered output. **See `references/rubrics.md` for the full per-block criteria.** Summary:

- **Score 8+** — block ships with confidence, criteria met.
- **Score 6–7** — block ships with the failing criteria visible; reader knows where to bring scepticism.
- **Score <6** — self-correction triggered. Three escalation tiers:

| Tier | Action                                                     | Example                                    |
|------|------------------------------------------------------------|--------------------------------------------|
| T1   | Broaden sources, retry block automatically                 | Block 4 underperformers: 3yr → 5yr window  |
| T2   | Ask the user for a hint (LinkedIn URL, sub-sector pick)    | Block 3 founder unresolved                 |
| T3   | Ship with confidence flag visible                          | After T1/T2 exhausted                      |

**Meta-rubric — hard floors below which the brief refuses to ship:**

1. **Founder identity uncertain** (Block 3 can't resolve LinkedIn endpoint) — stop and ask. Producing founder claims tied to the wrong person is the worst failure mode and the most legally exposed (GDPR Article 5 accuracy principle).
2. **Thesis-fit unresolved** (Block 2 can't classify into a single sub-sector with confidence ≥ 0.75 _and_ user can't disambiguate) — brief renders but Block 2 is explicitly marked "thesis-fit pending"; Blocks 4, 5, 6 fall back to the parent group rather than guessing.

## Evidence chain — every claim has a footprint

Every factual claim in the brief carries an inline citation marker:

| Marker         | Meaning                                                                          |
|---------------|----------------------------------------------------------------------------------|
| `[H]`          | Harmonic (`gold.harmonic_companies_act`)                                          |
| `[D]`          | Dealroom (`gold.dealroom_companies_act`)                                          |
| `[L]`          | LinkedIn (`gold.linkedin_organisation_act` or web LinkedIn)                       |
| `[C]`          | Crunchbase — **deprecated; do not use `gold.crunchbase_*`. Funding cites use `[D]` Dealroom.** |
| `[A·<date>]`   | Affinity entry or note (date stamp identifies the touch)                          |
| `[W]`          | Web search, with URL in the footer cite list                                       |
| `[F]`          | Founder's own deck or paste                                                        |
| `[LLM]`        | LLM synthesis across multiple sources — marks judgment, not reported fact          |

**Three non-negotiables:**

1. **No uncited claims.** If the skill can't cite something, it doesn't say it.
2. **LLM synthesis is labelled.** Where the brief draws a conclusion across sources, mark `[LLM]` and list the underlying citations.
3. **Confidence is per-claim, not just per-block.** High-confidence firmographics (HQ Munich, three sources agree) read differently from low-confidence inferences. Both can appear; the difference must be legible.

## Founder score — see `references/founder-score.md`

The EagleEye founder score (Base 3 + Tier 1 × +2 + Tier 2 × +1, capped at 10) appears in Block 3 as an expanded widget and inline elsewhere as a compact pill. Every score is always shown with its breakdown — surfacing the score without the breakdown is the failure mode that turns familiarity into anchoring. See the reference file for the full rubric, routing thresholds, and widget HTML pattern.

## EU AI Act + GDPR posture

The deep-dive isn't currently classified high-risk under Annex III, but we design to the high-risk standards defensively. Key obligations and how the skill satisfies them:

- **Transparency (Art. 50):** classification banner ("AI-generated, reviewed by [partner], not a recommendation"); every LLM-synthesised claim marked `[LLM]`.
- **Human oversight (Art. 14):** brief stops short of recommending; Block 8 = questions, not verdict.
- **Explainability (Art. 13 / GDPR Art. 22):** every score has a rubric-derived reason; founder-score widget shows the full breakdown.
- **Accuracy (GDPR Art. 5(1)(d)):** cross-source validation surfaces disagreements; cite list lets any claim be traced.
- **Data minimisation (GDPR Art. 5(1)(c)):** PII reveal (`pii_get_founder_email`, `pii_get_person_contact`) is opt-in, requires `reason_category`, audit-logged.
- **Right to contest / access (GDPR Art. 15, 22(3)):** footer notes the DPO contact; full export available on request.
- **No automated decision-making (GDPR Art. 22(1)):** the skill informs a human decision; founder-score is one input among many.
- **Logging:** every invocation logged via PostHog LLMA (see `posthog:llma-cc-*`).

## Footer of every brief

- **Skipped (MCP not configured)** — list any block omitted because a tool wasn't available, with the missing MCP named.
- **Cite list** — numbered expansion of all `[H]`/`[D]`/`[L]`/`[C]`/`[A]`/`[W]`/`[F]`/`[LLM]` markers with timestamps and exact source rows.
- **Save brief to Affinity? / Create deal?** — CTAs hitting `add_note_to_deal` or `add_deal`.
- **Reveal founder contact** — opt-in CTA hitting `pii_get_founder_email` with mandatory `reason_category`.
- **DPO contact line** — for any subject who wishes to see or contest the brief.

## Notes for the implementing agent

- **Start with the warehouse, not the web.** The inversion is the value.
- **Never auto-pull PII.** The founder email/phone reveal is a separate, opt-in CTA at the footer.
- **The brief is the artifact.** Markdown is fine for the chat preview; the HTML at a stable URL is what the investor actually opens.
- **Carry IDs forward.** The inline JSON header is what makes follow-up turns cheap.
- **When in doubt, ask.** Specifically: founder LinkedIn unresolved → ask. Sub-sector ambiguous → ask. Don't guess on identity.
- **Self-score honestly.** A brief that flags its own thin sections is more useful than one that pretends every block is solid.

## Files in this skill

- `SKILL.md` — this file.
- `references/rubrics.md` — full per-block rubric criteria, what triggers self-correction.
- `references/founder-score.md` — EagleEye founder-score rubric + the widget HTML pattern.
- `references/dag.md` — the orchestration DAG with concrete subagent prompts and return shapes.
- `assets/brief-template.html` — the HTML shell the brief renders into (Earlybird brand, sidebar, light/dark).

## Related skills

- `eb/ic/portfolio-catalysts/` — reads the catalogue.md the catalyst block depends on.
- `eb/ic/founder-deep-dive/` — Block 3's underlying primitive (when promoted from EagleEye MCP into a stand-alone skill).
- `eb/ic/call-debrief/` — post-call companion. Reads the brief's ID header and updates Affinity.
- `eb/ic/ic-memo/` — downstream artifact. Composes the deep-dive + call notes + partner stance into an IC memo.
- `shared/writing-orchestrator-skills/` — the meta-skill that explains the DAG / fan-out / evidence-pack pattern this skill uses.
- `shared/find-skills/` — to discover other skills the user might want.
