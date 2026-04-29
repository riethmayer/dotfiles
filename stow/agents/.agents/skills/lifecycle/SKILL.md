---
name: lifecycle
description: The full product development lifecycle from context loading to deployment. Use when someone asks about the SDLC, development process, "what's the workflow", "how do we build things", or needs to know which skill to use next.
---

# Product Development Lifecycle

Seven commands, one pipeline. Each step has a clear input and output.

```
/prime → /brief → /shape → /linear → /tdd → /review → /ship
```

## Destination vs Journey

Every step in the lifecycle produces a **destination** — a frozen artifact (or external state) — and is reached via a **journey** of one or more execution phases.

- **Destination = what's true when the step is done.** The brief, the shaped folder, the Linear issues, the green PR, the running service. Persists between sessions; can be reloaded.
- **Journey = how the agent gets there.** A single short turn for small work, or a multi-phase sequence for big work (see below).

When in doubt, **commit to the destination first** (write the file, create the issue, open the PR), even if the content is rough. A walking-skeleton destination is easier to iterate than a half-formed plan in a context window.

## Multi-phase HITL execution

Big HITL work — large `/shape` projects, multi-issue `/tdd` builds, sprawling `/review` loops — degrades quality if forced through one long context. Split into phases instead, each in a **fresh context** loading the **same canonical destination artifacts**:

```
Destination       @prd.md      @prd.md      @prd.md      @prd.md
                  @plan.md     @plan.md     @plan.md     @plan.md
                  "Phase 1"    "Phase 2"    "Phase 3"    "Phase 4"
                      ↓            ↓            ↓            ↓
Journey         [Phase 1]    [Phase 2]    [Phase 3]    [Phase 4]
                  Smart        Smart        Smart        Smart
                                                            ↓
                                                       (#4 — done)
```

Rules:

- Each phase loads the canonical destination (PRD + plan + relevant code) at start, in a fresh context.
- Each phase has one narrow scope ("implement issue 003", "fix CI on PR 3419", "draft 03-scenarios").
- Each phase commits its incremental output back to the destination — the next phase reads it from the file, not from chat history.
- Phase boundaries are also natural review points (HITL review one phase, then queue the next).

When NOT to split: small work that fits comfortably in one context (one bug fix, one tracer-bullet, one PR review). Splitting tiny work just adds overhead.

## The Pipeline

### 1. `/prime` — Load Context

**Input:** A project to work in
**Output:** Vision, strategy, roadmap, domain architecture in working memory

Reads `docs/vision/`, `docs/strategy/`, `docs/roadmap/`, and `domain-architecture` skill. Falls back to README + git log for simpler repos. Re-prime each session.

### 2. `/brief` — Justify the Work

**Input:** A problem or opportunity that needs leadership buy-in
**Output:** One-page decision brief (Situation, Stakes, Constraints, Key Question, Options, Recommendation)

Interviews the user to produce a board-ready brief that forces a business value debate before any design work begins. Answers the question "should we invest in this?" with concrete numbers and structured options.

The brief is the contract between leadership intent and engineering execution. In an agent-driven pipeline, it's the structured decision input that multiple agents can reason over independently.

**Decision gate:** Leadership reviews and approves before moving to `/shape`. No approval → no shaping.

### 3. `/shape` — Design the Work

**Input:** An approved brief — a problem the team has committed to solving
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

**Decision gate:** Review on mobile, fill in answers, then move to `/linear` when ready.

### 4. `/linear` — Commit to Linear

**Input:** Shaped Obsidian project (with answers filled in)
**Output:** Linear initiative, projects + issues with Gherkin scenarios, AFK/HITL classification, dependency ordering

Reads the shaped output, validates open questions are resolved, places work under a Linear initiative tied to a measurable outcome. Groups issues into projects by domain (infra, domain logic, UI, data). Each issue is a vertical slice with acceptance criteria, Gherkin scenarios, and explicit blocking relationships.

Classifies every issue as **AFK** (agent-autonomous) or **HITL** (needs human judgment). Copies `.feature` files into package directories. Merges ubiquitous language updates.

In non-EagleEye repos, use `/prd-to-issues` for GitHub-based projects.

### 5. `/tdd` — Build It

**Input:** Linear issues with Gherkin scenarios + `.feature` files in packages
**Output:** Working code with passing tests

Red-green-refactor in vertical slices:
1. Pick one scenario from the `.feature` file
2. Write a test for it (RED)
3. Write minimal code to pass (GREEN)
4. Refactor
5. Next scenario

Tests verify behavior through the port interface, not implementation. Integration-style, not unit mocks.

### 6. `/review` — Verify It

**Input:** PR with code changes
**Output:** Approved, green PR

Runs `/check-pr` loop: sync, fix CI, address CodeRabbit comments, push, wait for re-review. Repeat until green. CodeRabbit is the external reviewer — close comments to give it feedback.

### 7. `/ship` — Deploy It

**Input:** Green, approved PR
**Output:** Running in production

Squash-merges, monitors Cloud Run deployment, watches Sentry for errors.

## Supporting Skills

These plug into the pipeline at various points:

| Skill | Used During | Purpose |
|-------|-------------|---------|
| `/grill-me` | `/brief`, `/shape` | Stress-test decisions and design |
| `/user-story` | `/shape` step 5 | Write verb-noun capability cards |
| `/ubiquitous-language` | `/shape` step 5, `/linear` step 7 | Formalize domain terms |
| `/improve-codebase-architecture` | Before `/shape` | Find refactoring opportunities |
| `/prd-to-issues` | Alternative to `/linear` | For GitHub-based projects |

## When to Use What

| Situation | Start at |
|-----------|----------|
| New feature from scratch | `/prime` → `/brief` |
| Approved brief, ready to design | `/shape` → `/linear` |
| Bug fix | `/tdd` (skip brief/shape/linear) |
| Shaped work ready to build | `/linear` → `/tdd` |
| Code ready for review | `/review` |
| PR approved, ready to deploy | `/ship` |
| Need to understand the project | `/prime` |
| Need leadership buy-in | `/brief` |
| Want to stress-test an idea | `/grill-me` |
