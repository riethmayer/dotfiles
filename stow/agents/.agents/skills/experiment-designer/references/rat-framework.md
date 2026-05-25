# RAT Framework Reference

## The Split

**Opportunity Mapper handles:** OST — what/why (identifies assumptions as purple nodes)
**Experiment Designer handles:** RAT — how to test (designs experiments, returns validated evidence)

```
Opportunity Mapper identifies assumption (purple node)
         |
         v Handoff
Experiment Designer:
  1. Score (Evidence Gap x Impact / Effort)
  2. Design test
  3. Define success criteria
  4. Define drop conditions
         |
         v After testing
Return to Opportunity Mapper:
  Assumption -> Evidence (purple -> blue)
  or
  Assumption -> Disproven (remove from OST)
```

## RAT Entry Template

```markdown
### A#: [Assumption Title]

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Evidence Gap | **X** | What we don't know |
| Impact | X | How bad if wrong |
| Effort | S/M/L/XL | What testing requires |
| **Priority** | **X.X** | Test order |

**Hypothesis:** [Falsifiable statement with metric and threshold]

**Test Design:**
1. [Step 1]
2. [Step 2]
3. [Measurement approach]

**Success Criteria:**
- [Metric 1] > [threshold]
- [Metric 2] meets [condition]

**Drop Condition:**
- [Metric] < [threshold] -> [specific pivot]
- [Alternative failure mode] -> [response]

**Timeline:** [Start] - [End]
```

## Scoring Formula

```
Priority Score = (Evidence Gap x Impact) / Effort

Evidence Gap: 1-10 (what we don't know)
Impact: 1-10 (how bad if wrong)

Effort scale:
- S (1): Days, existing data
- M (2): Weeks, new analysis
- L (3): Month+, integration required
- XL (4): Quarter+, major build

Example: Evidence Gap 8 x Impact 9 / Effort M(2) = Priority 36
```

High priority = test first.

## Status Progression

```
UNTESTED -> TESTING -> VALIDATED/DISPROVEN/DEFERRED

UNTESTED: Assumption identified, test designed
TESTING: Experiment in progress
VALIDATED: Success criteria met -> becomes Evidence (E#)
DISPROVEN: Drop condition triggered -> remove/pivot
DEFERRED: Not blocking survival, park for later
```

## Handoff Formats

### Receiving from opportunity-mapper:

```markdown
### Handoff: A# from Opportunity Mapper

**Sub-opportunity:** [what opportunity this tests]
**Hypothesis:** [what we believe]
**Evidence gap:** [1-10]
**Impact:** [1-10]
```

Your job: Add test design, success criteria, drop conditions.

### Returning validated to opportunity-mapper:

```markdown
### Validation Complete: A# -> E#

**Original assumption:** [A# title]
**Test result:** [summary]
**Evidence collected:** [data/analysis file]
**New status:** VALIDATED

Update OST: Purple node -> Blue node
Evidence tag: E# - [finding summary]
```

### Returning disproven to opportunity-mapper:

```markdown
### Assumption Disproven: A#

**Original assumption:** [A# title]
**Test result:** [what we found]
**Drop condition triggered:** [which one]
**Pivot:** [what we're doing instead]

Update OST: Remove node or replace with new opportunity
```

## Integration with Survival

When survival stakes are active, add survival sequencing:

```
RAT vs SURVIVAL SEQUENCING

RAT priority: A# (score: X.X)
Survival priority: A# (blocks: [what])

Resolution: [which wins and why]
```

Survival sequencing can override RAT scores when assumptions have blocking dependencies.

## Local Sources

- RAT tracker: `docs/roadmap/riskiest-assumptions.md`
- Evidence base: `docs/data/analysis/`
- Evidence mapping: `docs/roadmap/roadmap-data-informed.md`
