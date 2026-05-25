---
name: interview-designer
description: "Use when you need an investor interview guide to test RAT assumptions about behavior, workflow, or decision criteria."
---

# Interview Designer

Design targeted interview scripts from RAT assumptions. Output is ready-to-execute interview guides that feed into `investor-interview-analyst` after execution.

## Context Loading

Read before designing:

1. `docs/puzzles/RAT.md` — focus on "Needs action" items
2. `docs/roadmap/2026-h1-roadmap.md` — open questions
3. `docs/roadmap/` — existing evidence

For question templates and interview structure: [references/interview-templates.md](references/interview-templates.md)

## When to Use Interviews vs Data

| Method | Use When | Example |
|--------|----------|---------|
| **Interview** | Behavior, preference, workflow, intent | "Would you use X?" |
| **Data analysis** | Coverage, accuracy, technical feasibility | "Can we match 80%?" |
| **Prototype test** | Usability, comprehension, trust | "Does this make sense?" |

**Rule:** If assumption involves investor *decision-making*, it's an interview.

## 3-Step Design Framework

### Step 1: Filter RAT for Interview Candidates

Pull assumptions where:
- Decision = "Needs action" (not "Look at data")
- Involves investor behavior, preference, or workflow
- Evidence gap > 5

### Step 2: Map Assumptions to Questions

- Past behavior > hypothetical intent
- Specific examples > general opinions
- Open questions > yes/no
- "Show me" > "Tell me"

### Step 3: Group & Structure

Max 3-4 assumptions per interview. Group by theme:

| Interview | Assumptions | Target | Duration |
|-----------|-------------|--------|----------|
| Workflow Discovery | A1, A2, A3 | Active investors | 30 min |
| Trust & Adoption | A4, A5 | Skeptical users | 25 min |
| Feature Validation | A6, A7 | Power users | 20 min |

## Response Templates

### When designing from RAT:
```
INTERVIEW DESIGN REQUEST

Scanning RAT.md for interview candidates...

Assumptions needing interviews:
| A# | Assumption | Weighted | Why Interview? |
|----|------------|----------|----------------|
| [from RAT] | [text] | [score] | [rationale] |

Proposed interview structure:
- Interview 1: [assumptions A, B] -> [target]
- Interview 2: [assumptions C, D] -> [target]

Generating guides...
```

### When designing for specific assumption:
```
INTERVIEW DESIGN: A# [assumption]

Assumption: [text]
Current evidence: [what we know]
Gap: [what we don't know]

Question progression:
1. [Warm-up] -> Build context
2. [Core] -> Test assumption
3. [Probe] -> Understand why
4. [Validate] -> Confirm understanding

Listen for:
- Validates: [signals]
- Invalidates: [signals]
- Unclear: [signals]
```

## Communication Style

- Assumption-first (what are we testing?)
- Behavior-focused (past > hypothetical)
- Structured output (ready to execute)
- Listen-for signals (how to interpret)
- Link to RAT (traceable validation)
