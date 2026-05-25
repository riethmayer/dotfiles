---
name: prd
description:
  "Use when committing shaped work to Linear — after /shape has produced numbered files (00-07)
  and the user says 'commit it'. Also use when drafting a PRD from scratch if no shaped output exists."
---

# PRD Writer

Commit shaped work to Linear, or draft a PRD from scratch with EagleEye context.

## Two Entry Points

### A. From `/shape` output (preferred)

When the user has already run `/shape` and says "commit it":

1. **Ask for the shaped files** — the user will provide or point to numbered files (`00-press-release` through `07-language`). These may be in a notes app, a local folder, or pasted inline.
2. **Incorporate answers** — check if the user filled in open question answer slots
3. **Load EagleEye context** (if not primed) — see [Context Loading](#context-loading)
4. **Validate strategic fit** — check against survival criteria and 5-lens score
5. **Write the PRD** using [references/prd-templates.md](references/prd-templates.md)
6. **Submit to Linear** — see [Linear Submission](#linear-submission)
7. **Copy `.feature` files** from `06-feature-files` into package directories
8. **Merge language** from `07-language` into `UBIQUITOUS_LANGUAGE.md` files

### B. From scratch (fallback)

When no shaped output exists:

1. `/prime` — load vision, strategy, roadmap, domain architecture
2. Explore the codebase — what exists, what doesn't
3. `/grill-me` — get all details, explore the problem
4. Sketch modules — look for deep module opportunities
5. Write the PRD using [references/prd-templates.md](references/prd-templates.md)
6. Submit to Linear — see [Linear Submission](#linear-submission)

## Context Loading

Read before writing:

1. Relevant OST from `docs/roadmap/` — opportunity + evidence tags
2. `docs/puzzles/RAT.md` — are underlying assumptions validated?
3. `docs/vision/README.md` — which horizon?
4. `docs/strategy/2026-strategy/README.md` — survival alignment?
5. `.agents/skills/domain-architecture/references/domain-map.md` — which bounded context?

## Mapping Shape → PRD

| Shape file | PRD section |
|------------|------------|
| `00-press-release.md` | TL;DR (distill to one sentence) |
| `01-overview.md` | The Bet + What + What Not + Success Criteria |
| `02-capabilities.md` | What (capability list → checklist) |
| `03-scenarios.md` | Linear issue descriptions (Gherkin per capability) |
| `04-implementation.md` | Dependencies + Timeline |
| `05-risks.md` | Risks table + Assumptions status |
| `06-feature-files.md` | Copied into `packages/` after Linear issues created |
| `07-language.md` | Merged into `UBIQUITOUS_LANGUAGE.md` files |

## Linear Submission

1. Find the right initiative or ask if one is missing
2. Create a project with a brief, clear title
3. Create one issue per capability (`verb-noun` as title)
4. Add Gherkin scenarios from `03-scenarios.md` to each issue description
5. Use [references/gherkin-format.md](references/gherkin-format.md) for formatting
6. Avoid sub-issues — scenarios go inline

## Writing Principles

### McKinsey Pyramid

1. **Answer first** — TL;DR answers "what and why" immediately
2. **Group logically** — MECE (mutually exclusive, collectively exhaustive)
3. **Order strategically** — most important first

### Ultra-Concise Rules

- **One page max** — if it doesn't fit, you haven't prioritized
- **No fluff** — every word earns its place
- **Tables over prose** — structured > narrative
- **Bullets over paragraphs** — scannable > readable
- **Links over duplication** — reference OST/RAT, don't copy

### EagleEye-Specific

- **Always link to OST** — which opportunity does this address?
- **Always show 5-lens** — solution-evaluator scores (Delight/Margin/Moat/Speed/Agent-ability)
- **Always check survival** — does this prove signals lead to meetings?
- **Always list What Not** — scope boundaries prevent creep

## PRD Types

| Type | Use When | Weight |
|------|----------|--------|
| **Full PRD** | Validated opportunity + evaluated solution | Full template |
| **Spike PRD** | Exploring unknowns before committing | Timeboxed question |
| **Kill PRD** | Documenting why we're NOT building | Closure record |

For templates: [references/prd-templates.md](references/prd-templates.md)

## Response Templates

```text
PRD BRIEF: [feature]
Type: [Full | Spike | Kill]
Decision: [Build | Defer | Don't build]
Scope in: [max 3 bullets]
Scope out: [max 3 bullets]
Dependencies: [systems, teams, data]
Success metric: [single measurable outcome]
First commit slice: [smallest deliverable]
```

If prerequisites are missing:

```text
PRD BLOCKER
Missing: [shaped output | validated opportunity | solution evaluation | survival alignment]
Required input: [exact artifact or decision needed]
```
