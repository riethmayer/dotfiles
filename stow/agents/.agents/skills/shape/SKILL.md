---
name: shape
description: Shape work into a walkable project folder — from press release down to feature files — then optionally commit to Linear. Use when user wants to shape work, write a PRD, plan a feature, scope a capability, or says "shape this".
---

# Shape

Create a PRD as 8 sequentially-readable files. Files descend from highest abstraction (press release) to lowest (feature files + language). Each file ends with open questions and empty answer slots for async review. Commit to Linear when ready.

## Process

### 1. Get the problem

Ask the user for a description of what they want to solve. Keep it conversational — they'll refine through the documents.

### 2. Determine output location

Check in order:
1. **User's personal agent config** — look for a `planning` or `notes` setting in `~/.agents/AGENTS.md` or `~/.claude/CLAUDE.md` that specifies a preferred app/folder (e.g., Obsidian vault path, Apple Notes, a local folder)
2. **Ask the user** — "Where do you want the shaped documents? (e.g., Obsidian vault, a folder in the repo, or just inline)"
3. **Fall back to repo** — create a `.planning/{feature-name}/` folder in the current repo

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

### 6. Write the project files

Output 8 numbered files to the chosen location. Files are numbered for sequential reading — highest level first, most detailed last.

### 7. Decision gate

After writing, tell the user where the files are and:

> Review the docs, fill in the answer slots, then come back and say "commit it" to create Linear issues.

Do NOT create Linear issues until explicitly asked.

## Output Format

### The abstraction gradient

```
1 - Projects/{feature-name}/
  00-press-release.md     ← why this matters (user/customer perspective)
  01-overview.md          ← problem, solution, scope, strategic fit
  02-capabilities.md      ← verb-noun capability cards
  03-scenarios.md         ← Gherkin acceptance criteria per capability
  04-implementation.md    ← modules, interfaces, what changes
  05-risks.md             ← assumptions, unknowns, dependencies
  06-feature-files.md     ← .feature file drafts ready for packages/
  07-language.md          ← new/changed terms for UBIQUITOUS_LANGUAGE.md
```

Reading top-to-bottom: from "why does this matter" → "what exact terms does the code use."

### File template

Every file follows this structure:

```markdown
---
date: {today}
tags: [prd, {feature-name}]
hubs:
  - "[[{feature-name}]]"
---

# {NN} — {Title}

{Content for this section}

---

## Open Questions

### {Question 1}?

> **Answer:**
>
>

### {Question 2}?

> **Answer:**
>
>
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

### 04-implementation.md

- **Modules to create**: new `packages/<domain>/<verb-noun>/` directories
- **Modules to modify**: existing packages that need changes
- **Interfaces**: port signatures, Zod schemas
- **Data changes**: schema migrations, new data sources
- **Dependencies**: what this depends on, what depends on this

No file paths or code snippets — they go stale. Describe intent and interfaces.

Open questions: technical unknowns, build-vs-buy, sequencing.

### 05-risks.md

- **Unvalidated assumptions**: what we believe but haven't proven
- **Dependencies**: external systems, other teams, data availability
- **Unknowns**: things we need to spike before committing

Open questions: which assumptions to test first, risk mitigation.

### 06-feature-files.md

Draft `.feature` file contents for each capability. These will be copied into `packages/<domain>/<verb-noun>/<verb-noun>.feature` when implementation starts.

```gherkin
# packages/sourcing/enrich-linkedin-contact-details/enrich-linkedin-contact-details.feature

Feature: enrich-linkedin-contact-details
  ...scenarios from 03...
```

Group by domain. Include the target file path as a comment above each feature.

Open questions: scenario completeness, missing edge cases discovered during implementation thinking.

### 07-language.md

New or changed terms that emerged during PRD writing. Grouped by bounded context.

```markdown
## Sourcing

| Term | Definition | Aliases to avoid | Status |
|------|-----------|-----------------|--------|
| **Signal** | A data point indicating founder activity | Indicator, metric | existing |
| **Triage** | Prioritization of founders by signal strength | Scoring, ranking | new |

## CRM

| Term | Definition | Aliases to avoid | Status |
|------|-----------|-----------------|--------|
| **Push** | Export a lead to external CRM system | Sync, export | clarified |
```

When shipping, these get merged into each domain's `UBIQUITOUS_LANGUAGE.md`.

Open questions: term conflicts across contexts, ambiguous definitions.

## Shipping to Linear

When the user says "ship it" (or similar):

1. Read the Obsidian project files (answers may have been filled in)
2. Update the PRD based on answers to open questions
3. Invoke the project-specific PRD writer if available (e.g., EagleEye's `prd-writer`)
4. If no project-specific writer, create Linear issues directly:
   - One project for the PRD
   - One issue per capability with Gherkin scenarios in the description
5. Copy `.feature` drafts from `06-feature-files.md` into package directories
6. Merge language additions from `07-language.md` into `UBIQUITOUS_LANGUAGE.md` files
