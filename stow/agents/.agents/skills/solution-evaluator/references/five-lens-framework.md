# Five Lens Framework Reference

## The Trio

```
1. OPPORTUNITY MAPPER (green)
   Outcome -> Opportunities -> Sub-opportunities
   Question: "Does this opportunity exist?"
   Output: OST with evidence/assumption tags

2. EXPERIMENT DESIGNER (purple)
   Assumptions -> Tests -> Validation
   Question: "Is our understanding correct?"
   Output: RAT with validated/disproven status

3. SOLUTION EVALUATOR (blue)
   Solutions -> Delight x Margin x Moat x Speed x Agent-ability
   Question: "Which solution should we build?"
   Output: Prioritized solution stack
```

## Detailed Lens Scoring

### 1. Delight (Desirability Risk)

> "Will users love this solution?"

| Score | Meaning | Signals |
|-------|---------|---------|
| **High** | Users will actively seek this out | Solves acute pain, "finally!" reaction |
| **Medium** | Users will use if presented | Nice to have, incremental improvement |
| **Low** | Users tolerate or work around | Solves our problem, not theirs |

**EagleEye context:** Does the investor say "this changed how I find founders" or "it's another tool"?

### 2. Margin-Enhancing (Viability Risk)

> "Does this create business value efficiently?"

| Score | Meaning | Signals |
|-------|---------|---------|
| **High** | Low cost, high leverage | Uses existing data, minimal maintenance |
| **Medium** | Reasonable ROI | Some integration work, moderate upkeep |
| **Low** | Expensive to build/maintain | Custom infrastructure, ongoing costs |

**EagleEye context:** Does this compound our existing data assets or require new infrastructure?

### 3. Hard-to-Copy / Moat (Defensibility Risk)

> "Can competitors replicate this?"

| Score | Meaning | Signals |
|-------|---------|---------|
| **High** | Proprietary, compounding | Uses our unique data, network effects |
| **Medium** | Temporary advantage | Head start, but copyable in 6-12 months |
| **Low** | Commoditized | Anyone with API access could build |

**EagleEye context:** Does Harmonic have the data to copy this tomorrow?

### 4. Speed (Time-to-Value)

> "How fast can we ship this?"

| Score | Meaning | Signals |
|-------|---------|---------|
| **High** | Hours to ship | Existing data, known patterns, agent-buildable |
| **Medium** | Days to ship | Some integration, moderate complexity |
| **Low** | Weeks to ship | Dependencies, unknowns, coordination needed |
| **No-go** | Months to ship | New infrastructure, blocking dependencies |

**Why this replaces "Feasibility":** With agent-assisted development, almost anything is buildable. The constraint shifted from "can we?" to "how fast?" In survival mode, speed is oxygen.

### 5. Agent-ability (Surface Risk)

> "Can agents invoke this capability?"

| Score | Meaning | Signals |
|-------|---------|---------|
| **High** | MCP-native, structured output | API-first, tool-callable, no UI required |
| **Medium** | API exists, needs wrapper | REST endpoint, but needs MCP adapter |
| **Low** | UI required for some workflows | Bulk edit, review, visual inspection |

**Why this replaces "Usability":** Traditional usability asks "can users navigate the UI?" But the thesis: agents become the new surface. If a capability is MCP-accessible, adoption follows from agent workflows.

## Scoring Matrix (Primary Filter: Delight x Moat)

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

| Filter | Effect |
|--------|--------|
| **Margin: Low** | Demote one tier (Ideal -> Build, Build -> Defer) |
| **Speed: No-go** | Block until dependencies resolved |
| **Speed: Low** | Flag for phasing (can we ship partial?) |
| **Agent-ability: Low** | Acceptable if bulk/review workflow, otherwise demote |

**Decision flow:**
1. Delight x Moat -> Quadrant
2. Margin check -> Adjust tier
3. Speed check -> Block or phase
4. Agent-ability check -> Surface strategy

## Evaluation Template

```markdown
### Solution: [Name]

**Addresses opportunity:** [O# from OST]
**Sub-opportunity:** [validated evidence tag]

| Lens | Score | Rationale |
|------|-------|-----------|
| Delight | H/M/L | [Why users will/won't love it] |
| Margin | H/M/L | [Build cost vs value created] |
| Moat | H/M/L | [Defensibility assessment] |
| Speed | H/M/L/No-go | [Hours/days/weeks/months] |
| Agent-ability | H/M/L | [MCP-native / needs wrapper / needs UI] |

**Quadrant:** [Ideal / Quick Win / Consider / Avoid]
**Speed gate:** [Clear / Needs phasing / Blocked]
**Surface:** [MCP-first / API+wrapper / UI required]

**Competitive check:**
- Can Harmonic build this? [Y/N - why]
- Can a startup copy this? [Y/N - why]
- What's our unfair advantage? [specific asset]

**Recommendation:** [BUILD FIRST / BUILD / DEFER / DON'T BUILD]
**Confidence:** [High/Medium/Low]
```

## Solution Stack Output

```markdown
## Solution Priority Stack

| Rank | Solution | D/Ma/Mo/Sp/Ag | Quadrant | Surface | Recommendation |
|------|----------|---------------|----------|---------|----------------|
| 1 | [name] | H/H/H/H/H | Ideal | MCP | BUILD FIRST |
| 2 | [name] | H/H/M/H/M | Quick Win | API | BUILD |
| 3 | [name] | M/H/H/M/H | Consider | MCP | BUILD (moat) |
| 4 | [name] | H/L/L/L/L | Quick Win | UI | DEFER |
| 5 | [name] | L/L/L/No/L | Avoid | - | DON'T BUILD |

**Legend:** D=Delight, Ma=Margin, Mo=Moat, Sp=Speed, Ag=Agent-ability

**Build sequence rationale:** [why this order]
**Surface strategy:** [which solutions MCP-first vs need UI]
```

## EagleEye-Specific Moat Indicators

Solutions score HIGH on moat if they leverage:

| Asset | Why Defensible |
|-------|----------------|
| Unified people graph | Harmonic has people, not cross-source resolution |
| Career transition history | Evertrace data + our enrichment |
| Investor preference model | Learned from our investors, not transferable |
| Relationship graph | Affinity data + meeting outcomes |
| Signal-to-meeting correlation | Proprietary feedback loop |

Solutions score LOW on moat if:
- Built on Harmonic API alone (they could feature-ize it)
- Generic ML on public data (anyone could train)
- UI/UX improvements (copyable in weeks)

## EagleEye-Specific Agent-ability Indicators

Solutions score HIGH on agent-ability if:

| Pattern | Why MCP-Native |
|---------|----------------|
| Single signal lookup | Tool call: `get_signal(founder_id)` |
| Enrichment request | Tool call: `enrich_person(linkedin_url)` |
| Match check | Tool call: `check_thesis_match(signal, investor)` |
| Warm path query | Tool call: `find_intro_path(founder, investor)` |

Solutions score LOW on agent-ability (UI justified) if:

| Pattern | Why UI Makes Sense |
|---------|-------------------|
| Bulk signal review | Scan 50 signals, mark relevant ones |
| ER conflict resolution | Human judgment on fuzzy matches |
| Thesis refinement | Interactive profile editing |
| Pipeline overview | Visual dashboard of signal flow |

**The test:** "Can an investor's Claude agent complete this task via MCP without opening a browser?"

## Survival Integration

When survival stakes are active:

```markdown
### Survival Check

Does this solution prove signals lead to meetings?
- [ ] Directly proves hypothesis -> Proceed
- [ ] Enables proof (infrastructure) -> Proceed if High Moat
- [ ] Neutral to hypothesis -> DEFER to Q3+
- [ ] Distraction -> DON'T BUILD

**Survival verdict:** [Proceed/Defer/Don't Build]
```

Survival can override Delight x Margin x Moat in 2026:
- Low Delight but proves hypothesis -> BUILD
- High Delight but doesn't prove hypothesis -> DEFER

## Vision Integration

Cross-reference with vision classification:

```markdown
### Vision Alignment

Vision fit: [Good/Poor]
Sustainability: [Improves/Worsens]
Classification: [Ideal/Vision Investment/Vision Debt/Danger]

DxMxM says: [recommendation]
Vision says: [classification]
Conflict? [Y/N - resolution]
```
