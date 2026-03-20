---
name: prime
description: Load project context (vision, strategy, roadmap, domain architecture) before deep work. Use before writing PRDs, design sessions, strategic decisions, or when starting work that needs full project awareness. Also triggers on "prime me", "load context", or "catch me up".
---

# Prime

Load project context so you can think about the product, not just the code.

## What This Does

Prime reads the project's strategic and architectural context into your working memory. After priming, you can write PRDs, design features, or make decisions with full awareness of vision, strategy, roadmap, and domain boundaries.

## Process

### 1. Find context sources

Look for these in order, read what exists:

| Source | Where to look | What it gives you |
|--------|--------------|-------------------|
| **Vision** | `docs/vision/README.md` | Product direction, horizons |
| **Strategy** | `docs/strategy/` (read AGENTS.md first) | Pillars, principles, resource allocation |
| **Roadmap** | `docs/roadmap/` (read AGENTS.md first) | Current epics, H1/H2 bets, decisions |
| **Domain architecture** | `.agents/skills/domain-architecture/` | Bounded contexts, packages, naming conventions |
| **Current focus** | `docs/strategy/current-focus.md` | What's active right now |
| **Assumptions** | `docs/puzzles/RAT.md` | What's validated, what's risky |

If a source doesn't exist, skip it — not every project has all of these.

### 2. Summarize what you loaded

Output a brief status to the user:

```
Primed on [project name]:
- Vision: [one-line summary]
- Strategy: [current pillars/focus]
- Roadmap: [what's in-flight]
- Domains: [N active, M planned]
- Open risks: [key unvalidated assumptions]
```

### 3. Note what's missing

If expected context is absent, say so:

```
Missing context:
- No docs/vision/ found — product direction unclear
- No domain-architecture skill — package boundaries unknown
```

## After Priming

You're now ready for deep work. Common next steps:

- `/write-a-prd` or `/prd-writer` — design a feature with full context
- `/grill-me` — stress-test a plan against strategy and roadmap
- `/user-story` — capture capabilities in the right domain

Priming is not persistent across conversations — re-prime in each new session if needed.

## For Projects Without Docs

If the project has no vision/strategy/roadmap docs, fall back to:

1. Read `README.md` and `CLAUDE.md` / `AGENTS.md` at project root
2. Scan for architecture patterns (`packages/`, `services/`, `apps/`)
3. Check git log for recent direction (`git log --oneline -20`)
4. Ask the user: "What's the current focus for this project?"

Output whatever context you found, even if sparse.
