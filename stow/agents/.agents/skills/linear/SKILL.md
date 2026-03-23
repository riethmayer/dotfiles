---
name: linear
description: "Break shaped work into Linear initiative, projects, and issues with AFK/HITL classification and dependency ordering. Use when user says 'commit it', 'push to linear', 'create tickets', or wants to turn shaped/designed work into trackable Linear issues."
---

# /linear

Turn shaped work into a Linear initiative with projects and issues. Ties work to outcomes, classifies by autonomy level (AFK/HITL), and orders by dependency.

## Process

### 1. Locate the input

Ask the user where the shaped docs are. Accepts:
- Obsidian project folder (8 numbered files from `/shape`)
- A PRD document
- A capability list
- Inline description

Read all input files. Check that open questions are resolved — if any remain unanswered, surface them before proceeding.

### 2. Strategic placement

Fetch current Linear initiatives using `list_initiatives` (include projects). Present them to the user and ask:

- **Which initiative does this work serve?** — or should we create a new one?
- **What outcome does it drive?** — tie to a measurable result (e.g., "per-industry precision >= 85%")
- **What's the target date?**

If creating a new initiative:
- Write a one-line summary
- Link to parent initiative if nested (e.g., under "H1 2026: Signal to Meeting")
- Set status, target date, health

### 3. Assess the work

Read the shaped docs through the lens of change:

**What's new?** — packages, modules, infrastructure, UI pages that don't exist today
**What's changing?** — existing code that needs refactoring, schema migrations, interface changes
**What's being removed?** — dead code, old collections, deprecated patterns
**What are the architecture decisions?** — new patterns, library choices, port/adapter boundaries

Summarize this as a brief change assessment and present to the user for confirmation before breaking down.

### 4. Group into projects

Organize work into Linear projects by **domain or area** (not by capability). Each project should be a coherent body of work that could be assigned to one team or agent.

Guidelines:
- **Infrastructure/platform work** in one project (ports, adapters, infra setup)
- **Domain logic** in one project (business rules, algorithms, computations)
- **UI/UX** in one project (pages, components, interactions)
- **Data/migration** in one project (seeding, cleanup, schema changes)
- Keep it to 3-5 projects. Fewer is better.

Present the proposed project grouping before creating issues.

### 5. Break into issues

For each project, create issues that are **independently shippable vertical slices** where possible. Each issue gets:

#### Title
Verb-noun format: `implement-taxonomy-port`, `build-binary-eval-runner`, `create-tree-browser-component`

#### Autonomy classification

Every issue is labeled either:

- **AFK** — can be completed by an autonomous agent without human decisions. Clear inputs, clear outputs, well-defined acceptance criteria. Examples: pure functions, port implementations, adapter wiring, data migration scripts, tests.
- **HITL** — requires human judgment during execution. Design decisions, UX choices, visual polish, ambiguous requirements, external stakeholder input. Examples: UI layout, prompt authoring, strategic trade-offs.

**Prefer AFK.** If an issue seems HITL, ask: can the HITL part be separated into a decision that unblocks AFK work? For example: "choose tree component library" (HITL, 5 min) unblocks "implement taxonomy tree browser" (AFK).

#### Description

```markdown
## Context
[One sentence: why this exists, what shaped doc it traces to]

## What to build
[Concise end-to-end description]

## Acceptance criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Gherkin scenarios
[If available from 03-scenarios.md or 06-feature-files.md, include inline]

## Dependencies
- Blocked by: [issue reference] or "None — can start immediately"
- Blocks: [what this unblocks]

## Autonomy
[AFK | HITL] — [one line why]
```

#### Dependency ordering

Create issues in dependency order. Use Linear's native relation/blocking API to set dependencies automatically — not just text references in descriptions. Each issue's "blocked by" and "blocks" relations are set programmatically via `save_issue`. Typical order:
1. Architecture decisions and spikes (HITL, unblock everything)
2. Port interfaces and types (AFK, unblock adapters)
3. Adapters and infrastructure (AFK, unblock domain logic)
4. Domain logic and business rules (AFK, unblock UI)
5. UI components and pages (HITL/AFK depending on design needs)
6. Integration, cleanup, and polish (AFK)

### 6. Confirm before creating

Present the full breakdown to the user:

```
Initiative: [name]
  Target: [date] | Outcome: [measurable result]

  Project: [name]
    [AFK] issue-title — one-line description (blocked by: none)
    [AFK] issue-title — one-line description (blocked by: above)
    [HITL] issue-title — one-line description (blocked by: none)

  Project: [name]
    ...

Total: N issues (X AFK, Y HITL)
Ready to start immediately: Z issues
```

Ask:
- Granularity OK? Too coarse or too fine?
- Dependencies correct?
- AFK/HITL marks right?
- Anything to merge, split, add, or remove?

### 7. Create in Linear

Only after user confirms:

1. **Create initiative** (if new) using `save_initiative`
2. **Create projects** using `save_project`, linked to initiative
3. **Create issues** in dependency order using `save_issue`:
   - Link to project
   - Add `AFK` or `HITL` label
   - Set dependency references using real issue IDs from previous creates
   - Include full description with Gherkin scenarios
4. **Report back** — list all created items with Linear URLs

### 8. Post-Linear actions (optional)

After Linear issues are created, offer:

- **Copy `.feature` files** from `06-feature-files.md` into package directories in the repo
- **Merge language** from `07-language.md` into `UBIQUITOUS_LANGUAGE.md` files
- **Create a handoff doc** summarizing what was committed and what's ready for AFK execution

## Principles

- **Outcomes over outputs** — every issue traces to a measurable result via initiative
- **AFK by default** — maximize what agents can do autonomously
- **Vertical slices** — each issue delivers something testable end-to-end
- **Dependencies are first-class** — explicit blocking relationships, not just order
- **Confirm before creating** — never create Linear items without user approval
- **Shaped docs are the source of truth** — don't invent scope beyond what was shaped
