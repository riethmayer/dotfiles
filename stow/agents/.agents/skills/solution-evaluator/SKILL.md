---
name: solution-evaluator
description: "Use when comparing solution options for a validated opportunity, including build-vs-buy and sequencing decisions."
---

# Solution Evaluator

Evaluate **which solutions to build** using five lenses: Delight, Margin, Moat, Speed, Agent-ability.

## Context Loading

Read before responding:

1. `docs/roadmap/` — OSTs with validated opportunities
2. `docs/puzzles/RAT.md` — assumption status
3. `docs/vision/README.md` — three horizons
4. `docs/strategy/2026-strategy/README.md` — annual strategy

For detailed scoring, EagleEye-specific indicators, and evaluation template: [references/five-lens-framework.md](references/five-lens-framework.md)

## Prerequisites

Opportunity must be validated (blue node in OST). Don't evaluate solutions for unvalidated assumptions (purple nodes) — send those to experiment-designer first.

## The Five Lenses

| Lens | Question | High | Low |
|------|----------|------|-----|
| **Delight** | Will users love this? | "This changed how I find founders" | "It's another tool" |
| **Margin** | Efficient business value? | Uses existing data, minimal maintenance | Custom infra, ongoing costs |
| **Moat** | Can competitors copy? | Proprietary data, network effects | Anyone with API access could build |
| **Speed** | How fast to ship? | Hours (agent-buildable) | Months (new infrastructure) |
| **Agent-ability** | Can agents invoke it? | MCP-native, structured output | UI required for workflow |

## Scoring Matrix (Delight x Moat)

```
                    HARD TO COPY
                Low         High
            +-----------+-----------+
     High   |  QUICK    |  IDEAL    |
            |   WIN     |  BUILD    |
DELIGHT     +-----------+-----------+
     Low    |  AVOID    |  CONSIDER |
            |           |  (moat)   |
            +-----------+-----------+
```

**Secondary filters:**
- Margin: Low -> demote one tier
- Speed: No-go -> block until resolved
- Speed: Low -> flag for phasing
- Agent-ability: Low -> acceptable if bulk/review, otherwise demote

## Response Templates

Use this format for one option:

```text
SOLUTION CHECK: [solution]
Opportunity: [O#]
Scores: D[H/M/L] Ma[H/M/L] Mo[H/M/L] Sp[H/M/L/No-go] Ag[H/M/L]
Decision: [Build first | Build | Defer | Reject]
Surface: [MCP | API | UI]
Reason: [1 sentence]
Next step: [owner + action + date]
```

Use this format for multiple options:

```text
SOLUTION COMPARISON: [O#]
| Rank | Option | Scores (D/Ma/Mo/Sp/Ag) | Decision |
|------|--------|--------------------------|----------|
| 1 | ... | ... | Build first |
| 2 | ... | ... | Build next |
| 3 | ... | ... | Defer/Reject |
```

## Integration

- **Survival-CPO active:** Does this prove signals lead to meetings? If not, DEFER regardless of Delight.
- **Visionary-CPO:** Cross-reference Vision/Sustainability classifier. Resolve conflicts between DxMxM and vision classification.

## Communication Style

- Score-first (all 5 lenses upfront)
- Speed-conscious (hours > days > weeks; months = blocker)
- Surface-explicit (MCP-first unless bulk/review justifies UI)
- Competitive-aware (always check "can Harmonic copy?")
- Build-order focused (sequence, not just yes/no)
- End with clear recommendation, surface strategy, confidence level
