# Product Review Workflow — Detailed Steps

## Phase 1: Context Loading

Read these files to build the strategic picture:

| File | What It Provides |
|------|-----------------|
| `docs/vision/README.md` | Three horizons, current priority |
| `docs/vision/radical-product-vision.md` | Full RPT framework |
| `docs/vision/current-focus.md` | H1 detail |
| `docs/strategy/2026-strategy/README.md` | Annual strategy |
| `docs/strategy/2026-strategy/MOATS.md` | Competitive position |
| `docs/puzzles/RAT.md` | Riskiest assumptions + evidence levels |

## Phase 2: Survival Gate

Apply the survival-cpo lens first — it's the strictest filter.

Load: `../../survival-cpo/references/survival-framework.md`

Checklist:
- Hard NO check (productivity tools, elaborate UIs, bottom-up requests, competing with Harmonic on public data)
- TTM pipeline stage (only Stage 1-2 in 2026)
- RAT survival sequencing (blocking dependencies first)
- Does this prove signals lead to meetings?

If Hard NO triggered: STOP. No further analysis needed.

## Phase 3: Vision Alignment

Apply the visionary-cpo lens.

Load: `../../visionary-cpo/references/vision-and-strategy.md`

Classify into Vision/Sustainability quadrant:
- Ideal (good fit + sustainable)
- Vision Investment (good fit, unsustainable — watch risk)
- Vision Debt (poor fit, sustainable — must repay)
- Danger (poor fit + unsustainable)

Check cascade alignment: which element of Playing to Win does this serve?

## Phase 4: Opportunity Mapping

Apply the opportunity-mapper lens.

Load: `../../opportunity-mapper/references/ost-framework.md`

- Map to existing OST or create new opportunity structure
- Tag sub-opportunities as Evidence (blue) or Assumption (purple)
- Check: is the opportunity investor-centric (not system-centric)?
- Check: are we solving user needs (not building solutions disguised as opportunities)?

## Phase 5: Assumption Check

Apply the experiment-designer lens.

Load: `../../experiment-designer/references/rat-framework.md`

- Which assumptions underpin this work?
- What's their RAT status? (Validated/Testing/Untested/Disproven)
- Score: Evidence Gap x Impact / Effort
- Are blocking assumptions validated?

## Phase 6: Solution Evaluation

Apply the solution-evaluator lens.

Load: `../../solution-evaluator/references/five-lens-framework.md`

Score across 5 lenses:
| Lens | Question |
|------|----------|
| Delight | Will users love this? |
| Margin | Low cost, high leverage? |
| Moat | Can competitors copy this? |
| Speed | How fast can we ship? |
| Agent-ability | Can agents invoke this via MCP? |

Place in quadrant (Delight x Moat):
- Ideal Build / Quick Win / Consider / Avoid

## Phase 7: Synthesis

Combine all lenses into a single recommendation:

```
PRODUCT REVIEW: [name]

SURVIVAL GATE: [Pass/STOP]
VISION FIT: [Ideal/Vision Investment/Vision Debt/Danger]
HORIZON: [H1/H2/H3/Off-roadmap]
OPPORTUNITY: [O# — investor need it serves]
ASSUMPTIONS: [A# — status, blockers]
5-LENS: D[H/M/L] Ma[H/M/L] Mo[H/M/L] Sp[H/M/L] Ag[H/M/L]
QUADRANT: [Ideal/Quick Win/Consider/Avoid]

RECOMMENDATION: [Build First / Build / Defer / Park / Don't Build]
RATIONALE: [1-2 sentences connecting the lenses]
NEXT STEPS: [specific actions]
```

## Roadmap Mode

When reviewing multiple items for roadmap planning:

1. Run each item through the full review
2. Stack rank by: Survival priority > Vision fit > 5-lens quadrant > Speed
3. Group into time horizons:
   - Now (unblocks survival hypothesis)
   - Next (validated, high moat)
   - Later (vision debt, needs more evidence)
   - Never (Hard NO, Danger quadrant, or Avoid)

Output format:
```
ROADMAP RECOMMENDATION

| Priority | Item | Survival | Vision | Quadrant | Speed | Action |
|----------|------|----------|--------|----------|-------|--------|
| 1 | [name] | Proves | Ideal | Ideal | Hours | Build now |
| 2 | [name] | Enables | Ideal | Quick Win | Days | Build next |
| ... | | | | | | |

PARKED: [items and why]
KILLED: [items and why]
```
