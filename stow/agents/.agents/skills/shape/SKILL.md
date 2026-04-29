---
name: shape
description: Shape work into a walkable project folder — press release, overview, capabilities, scenarios. Defaults to tracer-bullet vertical slices — smallest end-to-end path first, durable architecture second. Use when user wants to shape work, write a PRD, plan a feature, scope a capability, or says "shape this". After shaping, use /linear to commit to Linear.
---

# Shape

Create a PRD as 4 sequentially-readable files (00-03). Files descend from highest abstraction (press release) down to scenarios. Each file ends with open questions and empty answer slots for async review. When ready to commit, use `/linear`.

## Why 4 files, not 8

Earlier versions of this skill produced 8 files (press release → language). In practice the lower-abstraction files (implementation, risks, feature files, language) duplicate what's already implicit in 00-03 at different framings — and every iteration on the upstream files (rename a capability, change the schema, drop backwards compat) forces a sync pass through *all* lower files. The sync cost dwarfs the value.

The implementation/risks/feature-files/language details are better derived during `/linear` (when issues are created) or in the conversation that follows shaping, when the user has already committed to a direction. Don't write them speculatively at shape time.

If a project genuinely needs an upfront implementation doc (e.g. a migration spec with a known correct end state), write it as a separate design doc in `docs/plans/<date>-<slug>-design.md` — not as part of the shape PRD.

## Process

### 1. Get the problem

Ask the user for a description of what they want to solve. Keep it conversational — they'll refine through the documents.

### 2. Determine output location

Check in order:

1. **User's personal agent config** — look for a `planning` or `notes` setting in `~/.agents/AGENTS.md` or `~/.claude/CLAUDE.md` that specifies a preferred app/folder (e.g., Obsidian vault path, Apple Notes, a local folder)
2. **Project AGENTS.md / CLAUDE.md** — many repos document where design docs live (e.g., `docs/plans/YYYY-MM-DD-<slug>/`). Honor that convention over the skill's default.
3. **Ask the user** — "Where do you want the shaped documents? (e.g., Obsidian vault, a folder in the repo, or just inline)"
4. **Fall back to repo** — create a `.planning/{feature-name}/` folder in the current repo

### 3. Prime (if not already primed)

If `/prime` hasn't been run in this session, load project context now: vision, strategy, roadmap, domain architecture. This informs everything that follows.

### 4. Explore the codebase

Automatically discover what exists:

- Which packages/modules touch this problem space
- What interfaces already exist that could be extended
- What's been tried before (git log, existing code)

### 5. Grill — minimal

Only ask about gaps the codebase can't answer. Focus on:

- Ambiguous intent (multiple valid interpretations)
- Priority conflicts (this vs competing work)
- Scope boundaries (what's explicitly out)

### 5b. Default to a tracer-bullet shape

Shape the smallest end-to-end vertical slice that proves the whole pipeline works *before* designing the durable architecture. The slice itself follows the vertical-slice rules in `/linear` (and `/prd-to-issues` for GitHub repos) — what's mandatory here at the shape step is the **bias**:

- Tracer first, durable architecture second — even when the user asks for the proper version.
- The tracer surfaces which signals actually move the metric, which informs the durable schema. Skipping it spends weeks designing the wrong abstraction.
- Split into two top-level issues with explicit blocking: tracer unblocks the durable design.

Skip the tracer only when (a) the pipeline shape is already proven by earlier work or production code, or (b) the work is operational / migration with a known correct end state.

### 6. Write the project files

Output 4 numbered files to the chosen location. Files are numbered for sequential reading — highest level first, scenarios last.

### 7. Decision gate

After writing, tell the user where the files are and:

> Review the docs, fill in the answer slots, then run `/linear` to create initiative, projects, and issues.

Do NOT create Linear issues from this skill — that's `/linear`'s job. Implementation details, risks, feature files, and ubiquitous language land during `/linear` or in conversation, not as upfront artifacts.

## Output Format

### The abstraction gradient

```
{output-location}/{feature-name}/
  00-press-release.md     ← why this matters (user/customer perspective)
  01-overview.md          ← problem, solution, scope, strategic fit
  02-capabilities.md      ← verb-noun capability cards
  03-scenarios.md         ← Gherkin acceptance criteria per capability
```

Reading top-to-bottom: from "why does this matter" → "what behaviour proves it works."

### File template

Every file follows this structure:

```markdown
---
date: { today }
tags: [prd, { feature-name }]
hubs:
  - "[[{feature-name}]]"
---

# {NN} — {Title}

{Content for this section}

---

## Open Questions

### {Question 1}?

> **Answer:**

### {Question 2}?

> **Answer:**
```

The blockquote answer slots are empty — ready for voice-to-text input on mobile.

### 00-press-release.md

Write a backwards press release (Amazon-style). One page max. Written as if the feature already shipped:

- **Headline**: one sentence, customer benefit
- **Subheadline**: who it's for and what it enables
- **Problem paragraph**: the pain today
- **Solution paragraph**: what we built and why it matters
- **Quote from user**: fictional but realistic — what would an investor/team member say?
- **How it works**: 3-4 bullet points, no jargon
- **Call to action**: what the user does next

This is the north star. If the press release doesn't feel exciting, the feature isn't worth building.

Open questions: audience, positioning, whether this is exciting enough.

### 01-overview.md

- **Problem**: one paragraph, from the user's perspective
- **Solution**: one paragraph, what we'll build
- **Scope in**: 3-5 bullets max
- **Scope out**: what this is explicitly NOT
- **Success metric**: single measurable outcome
- **Strategic fit**: link to vision/strategy/roadmap (from `/prime`)

Open questions: strategic alignment, priority, scope boundaries.

### 02-capabilities.md

List each capability as a card (from `/user-story` format):

```markdown
### `verb-noun`

> One-line description.

**Domain:** bounded context
**Modalities:** web | mcp | cli | slack | cron
```

Open questions: missing capabilities, naming, domain placement.

### 03-scenarios.md

Gherkin acceptance criteria for each capability. 3-5 scenarios per capability.

```gherkin
Feature: verb-noun
  As an investor
  I want to verb noun
  So that benefit

  Scenario: happy path
    Given precondition
    When action through port
    Then observable outcome
```

Open questions: missing edge cases, unclear behavior, acceptance thresholds.

## Iterating with the user

After writing the 4 files, walk the user through them sequentially. Each file's open questions are gating — answers shift the direction of every downstream file. Common iteration patterns:

- A capability rename in 02 ripples to 03 feature names and scenario language.
- A schema decision (e.g. "no backwards compat") removes scenarios and tightens scope-out in 01.
- A new capability emerging during 02/03 questions (e.g. "let's also add a threshold sweep UI") gets added in place — don't defer to a later round.

**Edit in place as answers come in.** Don't accumulate a queue of "things to update next iteration." The whole point of the 4-file ceiling is that ripple cost stays manageable.

## Next step: /linear

When the user is ready to commit shaped work to Linear, point them to `/linear`. That skill handles:
- Strategic placement (initiative selection)
- Change assessment (new/changing/removing)
- Project grouping by domain
- Issue breakdown with AFK/HITL classification and dependency ordering
- Implementation details, `.feature` file generation, and ubiquitous-language merging — all derived from the 4 PRD files plus the conversation context

If the project genuinely needs a separate design doc (migration spec, data model with a known correct end state, ADR-adjacent rationale), write that as a standalone file outside the shape PRD — e.g. `docs/plans/<date>-<slug>-design.md`.
