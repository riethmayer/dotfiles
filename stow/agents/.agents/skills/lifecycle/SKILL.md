---
name: lifecycle
description: The full product development lifecycle from context loading to deployment. Use when someone asks about the SDLC, development process, "what's the workflow", "how do we build things", or needs to know which skill to use next.
---

# Product Development Lifecycle

Six commands, one pipeline. Each step has a clear input and output.

```
/prime → /shape → /prd → /tdd → /review → /ship
```

## The Pipeline

### 1. `/prime` — Load Context

**Input:** A project to work in
**Output:** Vision, strategy, roadmap, domain architecture in working memory

Reads `docs/vision/`, `docs/strategy/`, `docs/roadmap/`, and `domain-architecture` skill. Falls back to README + git log for simpler repos. Re-prime each session.

### 2. `/shape` — Design the Work

**Input:** A problem to solve
**Output:** Obsidian project folder (`1 - Projects/{name}/`)

Creates 8 numbered files descending from highest to lowest abstraction:

| File | Level |
|------|-------|
| `00-press-release.md` | Why this matters |
| `01-overview.md` | Problem, solution, scope |
| `02-capabilities.md` | `verb-noun` cards |
| `03-scenarios.md` | Gherkin acceptance criteria |
| `04-implementation.md` | Modules, interfaces |
| `05-risks.md` | Assumptions, unknowns |
| `06-feature-files.md` | `.feature` drafts for packages |
| `07-language.md` | Ubiquitous language additions |

Every file ends with open questions + empty answer slots for mobile review.

**Decision gate:** Review on mobile, fill in answers, then move to `/prd` when ready.

### 3. `/prd` — Commit to Linear

**Input:** Shaped Obsidian project (with answers filled in)
**Output:** Linear project + issues with Gherkin scenarios

Reads the shaped output, validates against EagleEye's 5-lens score and survival criteria, creates Linear issues per capability. Copies `.feature` files into package directories. Merges ubiquitous language updates.

In non-EagleEye repos, creates issues directly (Linear or GitHub).

### 4. `/tdd` — Build It

**Input:** Linear issues with Gherkin scenarios + `.feature` files in packages
**Output:** Working code with passing tests

Red-green-refactor in vertical slices:
1. Pick one scenario from the `.feature` file
2. Write a test for it (RED)
3. Write minimal code to pass (GREEN)
4. Refactor
5. Next scenario

Tests verify behavior through the port interface, not implementation. Integration-style, not unit mocks.

### 5. `/review` — Verify It

**Input:** PR with code changes
**Output:** Approved, green PR

Runs `/check-pr` loop: sync, fix CI, address CodeRabbit comments, push, wait for re-review. Repeat until green. CodeRabbit is the external reviewer — close comments to give it feedback.

### 6. `/ship` — Deploy It

**Input:** Green, approved PR
**Output:** Running in production

Squash-merges, monitors Cloud Run deployment, watches Sentry for errors.

## Supporting Skills

These plug into the pipeline at various points:

| Skill | Used During | Purpose |
|-------|-------------|---------|
| `/grill-me` | `/shape` step 4 | Stress-test design decisions |
| `/user-story` | `/shape` step 5 | Write verb-noun capability cards |
| `/ubiquitous-language` | `/shape` step 5, `/prd` step 7 | Formalize domain terms |
| `/improve-codebase-architecture` | Before `/shape` | Find refactoring opportunities |
| `/prd-to-issues` | Alternative to `/prd` | For GitHub-based projects |

## When to Use What

| Situation | Start at |
|-----------|----------|
| New feature from scratch | `/prime` → `/shape` |
| Bug fix | `/tdd` (skip shape/prd) |
| Shaped work ready to build | `/prd` → `/tdd` |
| Code ready for review | `/review` |
| PR approved, ready to deploy | `/ship` |
| Need to understand the project | `/prime` |
| Want to stress-test an idea | `/grill-me` |
