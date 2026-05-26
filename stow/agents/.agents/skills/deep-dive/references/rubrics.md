# /deep-dive — per-block rubrics

Each block of the brief produces three things alongside its prose:
1. A **self-score** (1–10).
2. A **per-criterion checklist** showing which criteria met / partial / missing.
3. When the score is below 8, an **explicit reason for low confidence** + the user-actionable next step that would raise it.

The criteria below are the **universal floor**. The investment-thesis app stores per-sub-sector overlays (e.g. for SalesTech, "rep-adoption mechanics" is a weighted criterion in Block 4); the deep-dive applies those overlays on top.

## Block 1 — Snapshot

| Criterion | Pass condition |
|--|--|
| Source coverage | ≥ 3 of 4 enrichment sources returned data (Harmonic, Dealroom, LinkedIn, Crunchbase) |
| Recency | Latest signal < 90 days old |
| Cross-source agreement | HQ, sector, headcount band agree across sources (or disagreement flagged for Block 6) |
| Domain valid | Resolves to a live website, not a parked page |

**Self-correction:** if < 3 sources, broaden to LinkedIn search by name + country before shipping. If headcount disagrees > 3× across sources, flag in Block 6 instead of averaging.

## Block 2 — Thesis fit

| Criterion | Pass condition |
|--|--|
| Single-leaf classification | One sub-sector, not "could be A or B" |
| LLM-judge confidence | ≥ 0.75 from the investment-thesis app's eval harness |
| Coverage owner | Named partner identified |
| Stance document | Active / paused / passing stance referenced |

**Self-correction:** if confidence < 0.75, show top-2 sub-sectors and ask user to disambiguate. Log the ambiguity as a ground-truth labelling event for the next eval run.

## Block 3 — Founder read

| Criterion | Pass condition |
|--|--|
| Identity resolved | Founder LinkedIn endpoint resolved (not just a name match) |
| `founder_deep_dive` returned | Non-empty narrative (not "insufficient public footprint") |
| Track record | ≥ 2 prior roles documented with dates |
| Founder-score interpreted | Score shown with the widget; reasoning visible per highlight |

**Self-correction:** if LinkedIn doesn't resolve, ask the user for the URL rather than guessing. Founders with names that match celebrities is the predictable failure mode.

## Block 4 — Market & competition

| Criterion | Pass condition |
|--|--|
| Direct competitors | ≥ 3 named with one-line positioning |
| Indirect / adjacent | ≥ 2 named |
| Underperformers | ≥ 2 historical underperformers in the sub-sector with documented failure mode |
| TAM/SAM/SOM | ≥ 2 methods triangulated (bottom-up + top-down minimum) |
| Differentiation hypothesis | Explicit — vs both incumbents and underperformers |

**Self-correction:** if < 2 underperformers, broaden window (3yr → 5yr → adjacent sub-sectors). If differentiation hypothesis is generic ("better UX, lower price"), flag and surface as a Block 8 question.

## Block 5 — Comparable deals

| Criterion | Pass condition |
|--|--|
| Volume | ≥ 3 Affinity comparables in last 18 months, same sub-sector |
| Verdict notes | ≥ 1 with an Earlybirder verdict note |
| Outcomes | Each entry has outcome state recorded (passed / portfolio / lost-to / unknown) |

**Self-correction:** if < 3 comparables in 18 months, expand to 24 then 36 months. Note the expansion in the brief — "we haven't seen many in this space" is itself a signal.

## Block 6 — Risk + tripwires

| Criterion | Pass condition |
|--|--|
| Disagreement surfacing | Cross-source disagreements from Block 1 surfaced as questions |
| Sub-sector tripwires | From thesis app, if available |
| Phrased as questions | Each tripwire = question, not assertion |
| Block 4 reflection | Failure-mode patterns from Block 4 underperformers reflected here |

**Self-correction:** if the sub-sector has no documented tripwires in the thesis app, fall back to Block 4 underperformer failure modes.

## Block 7 — Catalysts

| Criterion | Pass condition |
|--|--|
| Volume | ≥ 3 catalysts, each tied to a named portfolio asset / advisor / playbook |
| Specificity | Each tagged with stage and function |
| No generics | No "we have a strong network" — every catalyst is a specific person / playbook |

**Self-correction:** if < 3 specific matches found in the catalogue, show what's missing and propose additions — making each thin run a forcing function to enrich the Portfolio Excellence catalogue.

## Block 8 — Questions for the call

| Criterion | Pass condition |
|--|--|
| Volume | ≥ 10 questions |
| Linked | Each tied to a numbered open point from Blocks 1–6 |
| Top-3 marked | Highlighted for "if the call shortens to 15 min" |
| Underperformer-aware | ≥ 2 questions reference the underperformer story (what makes this different from deals that didn't work?) |

**Self-correction:** if fewer than 10 questions emerge naturally, the brief refuses to pad. Ship with what it has; note the gap. **Padded questions are worse than fewer real questions on a call.**

## Meta-rubric — hard floors

The brief refuses to render as "ready" if either floor is breached:

1. **Founder identity uncertain** — Block 3 can't resolve LinkedIn with confidence. Stop and ask.
2. **Thesis-fit unresolved** — Block 2 confidence < 0.75 _and_ user can't disambiguate. Render with thesis-fit pending; Blocks 4/5/6 fall back to parent group.

Above the floors, the brief always ships — but every block carries its score visibly, so the investor knows where to bring scepticism.
