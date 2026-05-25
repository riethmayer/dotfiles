---
name: product-review
description: "Use when one feature or roadmap item needs end-to-end review across survival, vision, opportunity, assumption, and solution lenses."
---

# Product Review

Orchestrate a comprehensive product review by sequentially loading all product lenses into the conversation. Unlike running individual skills, this builds cumulative context across all frameworks for a holistic recommendation.

## How It Works

This skill loads context from other skills' reference files and repo docs to build a complete picture. Each phase adds a lens — nothing is lost between steps.

For the full step-by-step workflow: [references/review-workflow.md](references/review-workflow.md)

## The 7 Phases

### Phase 1: Context Loading
Read strategy docs to establish the baseline:
- `docs/vision/README.md` — three horizons
- `docs/strategy/2026-strategy/README.md` — annual strategy
- `docs/puzzles/RAT.md` — current assumptions + evidence

### Phase 2: Survival Gate (strictest filter)
Load `../survival-cpo/references/survival-framework.md`
- Hard NO check (auto-reject list)
- TTM pipeline stage (Stage 1-2 only in 2026)
- If STOP: no further analysis needed

### Phase 3: Vision Alignment
Load `../visionary-cpo/references/vision-and-strategy.md`
- Vision/Sustainability quadrant (Ideal / Investment / Debt / Danger)
- Playing to Win cascade alignment

### Phase 4: Opportunity Mapping
Load `../opportunity-mapper/references/ost-framework.md`
- Map to OST (investor-centric outcomes)
- Tag evidence (blue) vs assumptions (purple)

### Phase 5: Assumption Check
Load `../experiment-designer/references/rat-framework.md`
- RAT status of underlying assumptions
- Blocking dependencies identified

### Phase 6: Solution Evaluation
Load `../solution-evaluator/references/five-lens-framework.md`
- 5-lens score: Delight x Margin x Moat x Speed x Agent-ability
- Quadrant placement

### Phase 7: Synthesis
Combine all lenses into a single recommendation.

## Output Prompt

Use this format for single-item review:

```text
PRODUCT REVIEW: [item]
Decision: [Build now | Build next | Defer | Park | Stop]
Why now: [1 sentence]
Lens summary: Survival[Pass/Stop], Vision[Quadrant], Opportunity[O#], Assumptions[A#], 5-Lens[D/Ma/Mo/Sp/Ag]
Main risk: [1 sentence]
Next step: [owner + action + date]
```

Use this format for roadmap prioritization:

```text
ROADMAP REVIEW
| Rank | Item | Decision | Why |
|------|------|----------|-----|
| 1 | ... | Build now | ... |
| 2 | ... | Build next | ... |

Parked: [items]
Stopped: [items]
```

## When to Use Individual Skills Instead

- **Just vision check?** Use `visionary-cpo`
- **Just survival filter?** Use `survival-cpo`
- **Just evaluate solutions?** Use `solution-evaluator`
- **Design experiments?** Use `experiment-designer`
- **Write a PRD after review?** Use `prd-writer`

Use this skill when you need the full picture, not just one lens.
