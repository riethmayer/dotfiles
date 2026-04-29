---
name: improve-codebase-architecture
description: Find deepening opportunities in a codebase, informed by the project's domain language and ADRs. Use when user wants to improve architecture, find refactoring opportunities, consolidate tightly-coupled modules, or make a codebase more testable and AI-navigable.
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

A **deep module** (Ousterhout, *A Philosophy of Software Design*) hides a large implementation behind a small interface. Deep modules are more testable, more AI-navigable, and let you test at the interface instead of inside.

## Glossary

Use these terms exactly in every suggestion. Consistent language is the point — don't drift into "component," "service," "API," or "boundary." Full definitions in [LANGUAGE.md](LANGUAGE.md).

- **Module** — anything with an interface and an implementation (function, class, package, slice).
- **Interface** — everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation** — the code inside.
- **Depth** — leverage at the interface: a lot of behaviour behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam** — where an interface lives; a place behaviour can be altered without editing in place. (Use this, not "boundary.")
- **Adapter** — a concrete thing satisfying an interface at a seam.
- **Leverage** — what callers get from depth.
- **Locality** — what maintainers get from depth: change, bugs, knowledge concentrated in one place.

Key principles (see [LANGUAGE.md](LANGUAGE.md) for the full list):

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

This skill is *informed* by the project's domain model and prior decisions. The domain language gives names to good seams; ADRs record decisions the skill should not re-litigate.

## Process

### 1. Explore

Read the project's domain glossary (`CONTEXT.md`, `UBIQUITOUS_LANGUAGE.md`, etc.) and any ADRs in the area you're touching first.

Then use the Agent tool with `subagent_type=Explore` to walk the codebase. Don't follow rigid heuristics — explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** — interface nearly as complex as implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

### 2. Present candidates

Present a numbered list of deepening opportunities. For each candidate:

- **Files** — which files/modules are involved
- **Problem** — why the current architecture is causing friction (use **shallow** / **leaky seam** / **lost locality** explicitly)
- **Dependency category** — see [REFERENCE.md](REFERENCE.md) for the four categories
- **Solution** — plain English description of what would change
- **Benefits** — explained in **leverage** and **locality**, plus how tests would improve

**Use the project's domain vocabulary for what's being modelled, and [LANGUAGE.md](LANGUAGE.md) vocabulary for the architecture.** If the project defines "Order," talk about "the Order intake module" — not "the FooBarHandler," and not "the Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting. Mark it clearly (e.g. *"contradicts ADR-0007 — but worth reopening because…"*). Don't list every theoretical refactor an ADR forbids.

Do NOT propose interfaces yet. Ask the user: *"Which of these would you like to explore?"*

### 3. Frame the problem space

Once the user picks a candidate, write a user-facing explanation of the problem space:

- The constraints any new interface would need to satisfy
- The dependencies it would rely on, and which category they fall into (see [REFERENCE.md](REFERENCE.md))
- A rough illustrative code sketch to ground the constraints — not a proposal, just a way to make the constraints concrete

Show this to the user, then immediately proceed to Step 4. The user reads while sub-agents work in parallel.

### 4. Design multiple interfaces

Spawn 3+ sub-agents in parallel using the Agent tool. Each must produce a **radically different** interface for the deepened module. Based on Ousterhout's "Design It Twice" — your first idea is unlikely to be the best.

Prompt each sub-agent with a separate technical brief (file paths, coupling details, dependency category, what sits behind the seam). Include both [LANGUAGE.md](LANGUAGE.md) vocabulary and the project's domain vocabulary in the brief so each sub-agent names things consistently. Give each agent a different design constraint:

- Agent 1: *"Minimise the interface — aim for 1–3 entry points max. Maximise leverage per entry point."*
- Agent 2: *"Maximise flexibility — support many use cases and extension."*
- Agent 3: *"Optimise for the most common caller — make the default case trivial."*
- Agent 4 (if applicable): *"Design around ports & adapters for cross-seam dependencies."*

Each sub-agent outputs:

1. Interface (types, methods, params — plus invariants, ordering, error modes)
2. Usage example showing how callers use it
3. What the implementation hides behind the seam
4. Dependency strategy and adapters (see [REFERENCE.md](REFERENCE.md))
5. Trade-offs — where leverage is high, where it's thin

### 5. Present and recommend

Present designs sequentially so the user can absorb each one, then compare in prose. Contrast by **depth** (leverage at the interface), **locality** (where change concentrates), and **seam placement**.

Give your own recommendation: which design you think is strongest and why. If elements from different designs would combine well, propose a hybrid. Be opinionated — the user wants a strong read, not a menu.

### 6. Side effects as decisions crystallise

- **Naming a deepened module after a concept not in the project glossary?** Add the term to `CONTEXT.md` / `UBIQUITOUS_LANGUAGE.md` right there. Create the file lazily if it doesn't exist.
- **Sharpening a fuzzy term during the conversation?** Update the glossary in place.
- **User rejects a candidate with a load-bearing reason?** Offer an ADR, framed as: *"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"* Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing — skip ephemeral reasons ("not worth it right now") and self-evident ones.

### 7. Create GitHub issue

Once the user picks an interface (or accepts the recommendation), create a refactor RFC as a GitHub issue using `gh issue create`. Use the template in [REFERENCE.md](REFERENCE.md). Do NOT ask the user to review before creating — just create it and share the URL.
