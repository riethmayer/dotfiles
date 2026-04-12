---
name: rdcl
description: Apply the Radical Product (RDCL) Toolkit to define vision, strategy, roadmap, and execution plan for any product or feature. Use this skill whenever the user wants to do product thinking, define or refine a product vision, develop product strategy, evaluate strategic options, create a strategic roadmap, build an execution plan, or says "rdcl", "radical product", "product vision", "product strategy". Also trigger when a user is starting a new product from scratch, re-evaluating direction, preparing for a pivot, or when product direction is unclear and they need to think before they build. This skill comes before /shape — use it when the "what to build" is still fuzzy. Based on the RDCL Toolkit v3.1.0 (CC BY-SA 4.0) by radicalproduct.com.
---

# RDCL — Radical Product Toolkit

Vision-driven product thinking that produces 4 sequential documents flowing from "why this matters" down to "what to do Monday morning." The framework prevents two common failure modes: building without direction (iteration-led) and strategizing without grounding (vision-led but impractical).

## Process

### 1. Gather context

The current conversation likely already contains useful context — extract what you can before asking questions. Look for: who the users are, what problem is being solved, what competitors/solutions exist, and any constraints.

Only ask about gaps. If the user has already described the product, don't re-interview — proceed directly.

### 2. Work through the 4 parts sequentially

Each part builds on the previous. Read the reference file for each part before writing it — they contain the frameworks, templates, and fill-in-the-blank worksheets.

#### Part 1: Vision (read [vision.md](references/vision.md))

A fill-in-the-blanks worksheet that forces clarity: "Today, when [users] want to [outcome], they have to [current solution]. This is unacceptable because [shortcomings]. We envision a world where [resolution]. We're bringing this about through [approach]."

The vision must be problem-centered (not "be the leader in X"), shared by customers (they'd nod along), and concrete (you can picture the end state). These three criteria matter because a vision that fails any of them won't align your team or resonate with users — it becomes a poster on the wall instead of a decision-making tool.

#### Part 2: Strategy (read [strategy.md](references/strategy.md))

Three sub-steps that force you to think about survival alongside ambition:

1. **Sustainability Analysis** — identify the top existential risks (Technology, Legal, Financial, Personnel, Stakeholder) and write a Sustainability Statement. This matters because the best vision is worthless if you can't survive long enough to achieve it.

2. **RDCL Strategy Canvas** — generate 2-3 distinct strategic options. Each defines Real Pain Points, Design (interface + identity), Capabilities (hard-to-copy assets), and Logistics (pricing, delivery, support). Multiple options prevent anchoring on the first idea.

3. **Vision/Sustainability Test** — plot each strategy's R, D, C, L items on a 2x2 (Vision Fit x Sustainability). Items should land in "Ideal" (good fit + sustainable). Items in "Vision Investment" (good fit but unsustainable) are risky. Items in "Vision Debt" (sustainable but poor fit) accumulate debt. Items in "Danger" (poor fit + unsustainable) should be rejected unless they unlock future opportunities.

#### Part 3: Strategic Roadmap (read [roadmap.md](references/roadmap.md))

Group chosen strategy items into Initiatives, assign responsible teams/people, and set Now/Next/Later milestones. "Now" milestones should be written in past tense to make them concrete: "Launched MVP to 50 beta testers" not "Launch MVP."

#### Part 4: Execute & Measure (read [execute.md](references/execute.md))

For each "Now" initiative: define Key Metrics (favor leading over trailing — you want early signals, not lagging confirmation), Hypotheses (If [activity]... Then [outcome]... Because [reasoning]), and concrete Tasks.

Hypotheses must be falsifiable. "If we build it, they will come" is not a hypothesis. "If we launch in r/SkincareAddiction, then we'll get 500 installs in the first week, because the subreddit has 2M members actively seeking ingredient transparency" is.

### 3. Determine output location

1. Check if the user specified a location
2. If not, ask
3. Fall back to `.planning/rdcl/` in the current repo

### 4. Write the files

```
00-vision.md              <- Problem-centered vision statement
01-strategy.md            <- Sustainability + RDCL Canvas + V/S Test
02-roadmap.md             <- Initiatives x Teams x Now/Next/Later
03-execute-and-measure.md <- Metrics, hypotheses, tasks per initiative
```

### 5. Quality check

Before finishing, verify these — each catches a specific failure mode:

- **Vision is problem-centered, shared, concrete** — otherwise it's a corporate platitude that won't guide decisions
- **Strategy has no internal contradictions** — e.g., a Design element that depends on a Capability you chose not to develop means the strategy will fail on contact with reality
- **Chosen strategy items mostly land in "Ideal" quadrant** — too many in "Vision Investment" means you're overextended; too many in "Vision Debt" means you're drifting from your vision
- **Roadmap "Now" milestones are past tense** — this forces concreteness ("Shipped beta to 50 users" vs. the vague "Ship beta")
- **Hypotheses are falsifiable** — each "If... Then..." must reference something you can actually measure
- **Key Metrics favor leading indicators** — trailing metrics (revenue, retention) confirm success too late to course-correct

## Example: What good output looks like

**Good vision:** "Today, when health-conscious parents want to know if their baby's products contain harmful chemicals, they have to cross-reference Yuka, EWG, and Reddit threads. This is unacceptable because no single source covers all categories with transparent, cited data..."

**Bad vision:** "We want to be the leading chemical safety platform, empowering consumers worldwide with AI-driven insights." (Not problem-centered, not shared by customers, not concrete.)

**Good hypothesis:** "If we import Open Beauty Facts' cosmetics catalog, then 85%+ of barcode scans will return results, because OBF has 200K+ beauty products with EAN codes."

**Bad hypothesis:** "If we build a great app, users will love it." (Not falsifiable, no measurable outcome.)
