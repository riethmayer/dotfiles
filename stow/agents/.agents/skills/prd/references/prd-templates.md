# PRD Templates

## Full PRD Template

```markdown
# [Feature Name]

**Status:** Draft | Review | Approved
**Owner:** [name]
**Date:** [YYYY-MM-DD]
**Horizon:** H1 | H2 | H3

---

## TL;DR

[One sentence: what we're building and why it matters]

## The Bet

| Dimension | Assessment |
|-----------|------------|
| **Opportunity** | [O# from OST] |
| **Evidence** | [E# tags] |
| **Assumptions** | [A# - status: Validated/Testing/Untested] |
| **Survival** | [Proves hypothesis / Enables proof / Neutral] |

## 5-Lens Score

| Lens | Score | Rationale |
|------|-------|-----------|
| Delight | H/M/L | [one line] |
| Margin | H/M/L | [one line] |
| Moat | H/M/L | [one line] |
| Speed | H/M/L | [hours/days/weeks] |
| Agent-ability | H/M/L | [MCP/API/UI] |

**Quadrant:** [Ideal / Quick Win / Consider / Avoid]

## What

[3-5 bullets max - what we're building]

- [ ] [Capability 1]
- [ ] [Capability 2]
- [ ] [Capability 3]

## What Not

[Explicit scope boundaries - equally important]

- ~~[Out of scope 1]~~
- ~~[Out of scope 2]~~

## Success Criteria

| Metric | Target | Measurement |
|--------|--------|-------------|
| [metric] | [number] | [how we measure] |

## Dependencies

| Dependency | Status | Owner | Blocks |
|------------|--------|-------|--------|
| [what] | Done/In Progress/Blocked | [who] | [what it blocks] |

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [risk] | H/M/L | H/M/L | [action] |

## Timeline

| Milestone | Date | Deliverable |
|-----------|------|-------------|
| [phase] | [date] | [what's done] |

---

**Decision:** Build | Don't Build | Defer to [when]
**Reviewer:** [name]
```

## Spike PRD Template

```markdown
# Spike: [Question]

**Timebox:** [X days]
**Owner:** [name]

## Question
[What we're trying to learn]

## Approach
[How we'll investigate]

## Success
[How we'll know we're done]

## Output
[Deliverable: doc/prototype/analysis]
```

## Kill PRD Template

```markdown
# Kill: [Feature Name]

**Decision:** Don't Build
**Date:** [YYYY-MM-DD]

## Why Not

| Lens | Issue |
|------|-------|
| [failing lens] | [reason] |

## What Instead
[Alternative approach or explicit park]
```
