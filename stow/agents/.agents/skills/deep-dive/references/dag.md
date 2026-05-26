# /deep-dive — orchestration DAG, subagent prompts, return shapes

The eight blocks compose as a dependency DAG with two parallel fan-out points. Run them as below; this is non-negotiable for context-budget reasons.

## The DAG

```
ID resolution                       (caller, sequential)
      ↓
Block 2: Thesis fit                 (caller, cheap) → sub_sector_slug
      ↓
┌─── parallel fan-out (1 message, 4 Task calls) ───┐
│ Block 1: Snapshot                    (subagent)  │
│ Block 3: Founder read                (subagent)  │
│ Block 4: Market + competition        (subagent)  │
│ Block 5: Comparable deals            (subagent)  │
└──────────────────────────────────────────────────┘
      ↓
┌─── parallel fan-out (1 message, 2 Task calls) ───┐
│ Block 6: Risk + tripwires            (caller)    │
│ Block 7: Catalysts                   (subagent)  │
└──────────────────────────────────────────────────┘
      ↓
Block 8: Questions for the call       (caller)
```

Three message turns total. ~4× wall-clock speedup over sequential. Caller context stays under ~30k tokens regardless of how much data the warehouse returns to subagents.

## Subagent contract — every block follows this shape

### Input prompt (what the subagent receives)

```
You are running Block <N>: <name> of a deep-dive on <company>.

Resolved IDs:
  linkedin_company_url: <url>
  affinity_org_id: <id>
  harmonic_urn: <urn>
  dealroom_company_id: <id>
  crunchbase_permalink: <permalink>
  founder_linkedin_urls: [<url>, ...]
  thesis_node_slug: <slug>  (if Block 2 has run)

Block rubric (see references/rubrics.md):
  <criteria>

Required output shape:
  rendered: HTML for this block (per template snippets in references/)
  evidence: {
    citations: [{marker: "[H]", source: "harmonic_companies_act", url: "...", row_id: "..."}, ...],
    key_claims: ["...", "...", ...],     // for downstream blocks 6 & 8
    flags: ["headcount disagrees: L=18, H=47, D=31", ...],
    ids: { ... }                          // any new IDs resolved
  }
  self_score: 1-10
  rubric_check: [{criterion: "...", met: true|false|partial, reason: "..."}, ...]

Do not consume the user's full prompt or prior block outputs.
Do not call Block 8 / synthesis tools.
```

### Return shape (what the subagent gives back)

Two parts. The caller stitches `rendered` into the brief HTML and consumes `evidence` for downstream synthesis.

**`rendered`** — HTML for the block, conforming to the brief template's section structure (`<section class="section" id="sec-block-<N>">…</section>`).

**`evidence`** — structured JSON:

```json
{
  "block": 4,
  "self_score": 7,
  "rubric_check": [
    {"criterion": "≥3 direct competitors", "met": true},
    {"criterion": "≥2 underperformers", "met": "partial", "reason": "only 1 found in 3yr window, expanded to 5yr per T1 self-correction"},
    {"criterion": "TAM/SAM/SOM ≥2 methods", "met": true},
    {"criterion": "differentiation hypothesis explicit", "met": true}
  ],
  "citations": [
    {"marker": "[H]", "source": "harmonic_companies_act", "row_id": "harmonic:co_4f2", "url": "https://app.harmonic.ai/companies/4f2"},
    {"marker": "[D·dead]", "source": "dealroom_companies_act", "row_id": "dealroom:co_8a1", "note": "shut down 2024-Q3"}
  ],
  "key_claims": [
    "3 direct competitors in EU: Bigfoot, Slipstream, Vortex",
    "Bigfoot raised €18M Series A in 2024 [C]",
    "Underperformer: Roomex acqui-hired 2022 — lacked enterprise-grade auth",
    "Differentiation hypothesis: native multi-tenant from day one"
  ],
  "flags": []
}
```

The caller composes Block 6 by passing the evidence packs from Blocks 1, 3, 4 (the only ones whose flags + claims feed Block 6). The caller composes Block 8 by passing all upstream evidence packs.

## Block 2 — thesis-fit prompt (runs in caller)

```
Classify <company> against the Earlybird investment-thesis taxonomy.

Inputs from Block 1's snapshot subagent:
  primary_sector: <from Harmonic + Dealroom>
  description: <one-line>
  geography: <country>
  customer_type: <B2B / B2C / B2B2C>

Call the investment-thesis classifier (mcp__investment_thesis__classify, or
sql query against the taxonomy table if MCP unavailable).

Required output:
  thesis_node_slug: <slug>
  thesis_node_path: "Applications > B2B > SalesTech"
  llm_judge_confidence: 0.0-1.0
  coverage_owner: <named partner>
  stance: "active" | "paused" | "passing"
  stance_note: <if any>

If llm_judge_confidence < 0.75, ask the user to disambiguate between the
top-2 candidates before fanning out the rest of the blocks. Log the
ambiguity event for the eval harness.
```

## Block 4 — market + competition prompt (subagent)

The heaviest block. Concretely:

```
Block 4: Market + competition for <company>.

Resolve competitors from THREE sources, then synthesise:

1. Harmonic similar-companies:
   sql_query("SELECT * FROM gold.harmonic_companies_act
              WHERE sector = '<sector>' AND country IN ('<countries>')
              ORDER BY headcount DESC LIMIT 30")

2. Dealroom comparables:
   sql_query("SELECT * FROM gold.dealroom_companies_act
              WHERE industry = '<industry>'
              ORDER BY employees_latest DESC LIMIT 30")

3. Affinity passed-deals (the underperformer query):
   sql_query("SELECT * FROM affinity_deals
              WHERE thesis_node_slug = '<slug>' AND status = 'passed'
              AND created_at > NOW() - INTERVAL '5 years'")
   Join with Crunchbase/Dealroom funding outcomes to find which ones
   subsequently died, got acqui-hired below valuation, or down-rounded.

Output:
  - 3 direct competitors named, one-line each
  - 2 indirect/adjacent named
  - 2 underperformers with documented failure mode
  - TAM/SAM/SOM triangulation (bottom-up + top-down)
  - Differentiation hypothesis vs both incumbents and underperformers
```

## Block 6 — risk + tripwires (runs in caller)

```
Block 6: Risk + tripwires for <company>.

Inputs (from caller's accumulated evidence packs):
  block_1_flags: <flags array from Block 1 evidence pack>
  block_3_flags: <flags array from Block 3>
  block_4_underperformer_failure_modes: <from Block 4 key_claims>
  thesis_app_subsector_tripwires: <from thesis app or null>

Synthesise:
  - For each cross-source disagreement in block_1_flags: phrase as question.
  - For each thesis tripwire: phrase as question.
  - For each underperformer failure mode: derive "what would prevent the
    same outcome here?" question.

Output: bulleted list of questions, each citing the upstream evidence
(e.g. "[from Block 1] headcount disagrees L=18 / H=47 — what's the
actual team size?").
```

## Block 8 — questions for the call (runs in caller)

```
Block 8: Questions for the call.

Inputs (full evidence packs from all upstream blocks):
  - Block 1 key_claims + flags
  - Block 2 thesis stance + open points
  - Block 3 founder track-record questions + score breakdown
  - Block 4 differentiation hypothesis + underperformer failure modes
  - Block 5 comparable-deal verdicts
  - Block 6 risk questions

Synthesise 10 ranked questions:
  - Each tied to a numbered open point from Blocks 1-6.
  - Top 3 marked for "if the call shortens to 15 min".
  - ≥ 2 questions reference the underperformer story.
  - If fewer than 10 emerge naturally, ship with what's there — DO NOT PAD.

Output format: numbered list, each question followed by a small italic
"why we ask" line citing the upstream open point.
```

## Why the caller-vs-subagent split matters

| Where | Block | Reason                                                   |
|-------|-------|----------------------------------------------------------|
| Caller | ID resolution | Sequential; everything else needs IDs. |
| Caller | Block 2 (Thesis fit) | Cheap, small in/out. Emits sub_sector_slug for the fan-out. |
| Subagent | Block 1, 3, 4, 5 | Heavy SQL / similar-companies / founder narrative. Bulky inputs → compressed evidence pack outputs. |
| Caller | Block 6 (Risk) | Synthesises across evidence packs. Cheap with structured inputs. |
| Subagent | Block 7 (Catalysts) | Independent catalogue query. |
| Caller | Block 8 (Questions) | Synthesises everything. The brief's most expensive single LLM call — done in caller because it must see all evidence packs together. |

See `shared/writing-orchestrator-skills/SKILL.md` for the general pattern this skill instantiates.
