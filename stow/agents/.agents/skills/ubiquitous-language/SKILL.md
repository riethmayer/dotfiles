---
name: ubiquitous-language
description: Extract a DDD-style ubiquitous language glossary scoped to bounded contexts. Each domain boundary gets its own UBIQUITOUS_LANGUAGE.md — the same term can mean different things in different contexts. Use when user wants to define domain terms, build a glossary, harden terminology, create a ubiquitous language, or mentions "domain model" or "DDD".
---

# Ubiquitous Language

Extract and formalize domain terminology from the current conversation, scoped to bounded contexts.

## Core principle: one glossary per bounded context

Each domain boundary (typically a packages/ subdirectory, service, or module) gets its own `UBIQUITOUS_LANGUAGE.md`. The same term can — and often does — mean something different across boundaries. "Policy" in auth is not "Policy" in billing. Don't disambiguate by making terms more complex; disambiguate by scoping them to their context.

```
packages/
  billing/
    UBIQUITOUS_LANGUAGE.md   ← "Policy" = payment retry rules
  auth/
    UBIQUITOUS_LANGUAGE.md   ← "Policy" = access control rules
  shipping/
    UBIQUITOUS_LANGUAGE.md   ← "Policy" = carrier selection rules
```

## Finding the right bounded context

Use progressive disclosure to locate domain boundaries:

1. **Check for a domain-architecture skill** — look for `.agents/skills/domain-architecture/` in the repo. If it exists, read its `references/domain-map.md` for the authoritative list of bounded contexts and their locations.
2. **If no domain-architecture skill**, scan `packages/` (or `services/`, `domains/`, `modules/`) for directory boundaries.
3. **If monolith**, look for namespace patterns in the code (e.g., `src/billing/`, `src/auth/`).
4. **Ask the user** which context the conversation belongs to if still unclear.

The glossary file goes in the bounded context's root directory — next to `package.json` or the module's entry point.

## Process

1. **Identify the bounded context** using the discovery steps above.
2. **Scan the conversation** for domain-relevant nouns, verbs, and concepts within that context.
3. **Identify problems**:
   - Same word used for different concepts *within this context* (ambiguity)
   - Different words used for the same concept (synonyms)
   - Vague or overloaded terms
4. **Propose a canonical glossary** with opinionated term choices.
5. **Write to `UBIQUITOUS_LANGUAGE.md`** in the domain boundary's directory.
6. **Output a summary** inline in the conversation.

If a term appears to cross boundaries, flag it — that's a context mapping concern, not something to solve by widening a single glossary.

## Output Format

Write the `UBIQUITOUS_LANGUAGE.md` file with this structure:

```md
# Ubiquitous Language: [Context Name]

> Bounded context: [brief description of what this domain owns]

## Order lifecycle

| Term | Definition | Aliases to avoid |
|------|-----------|-----------------|
| **Order** | A customer's request to purchase one or more items | Purchase, transaction |
| **Invoice** | A request for payment sent to a customer after delivery | Bill, payment request |

## People

| Term | Definition | Aliases to avoid |
|------|-----------|-----------------|
| **Customer** | A person or organization that places orders | Client, buyer, account |

## Relationships

- An **Invoice** belongs to exactly one **Customer**
- An **Order** produces one or more **Invoices**

## Context mappings

Terms that cross into or from other bounded contexts:

| Term (here) | Term (other context) | Relationship |
|-------------|---------------------|--------------|
| **Customer** | **User** (auth) | Customer wraps a User identity with purchasing capabilities |

## Example dialogue

> **Dev:** "When a **Customer** places an **Order**, do we create the **Invoice** immediately?"
> **Domain expert:** "No — an **Invoice** is only generated once a **Fulfillment** is confirmed."

## Flagged ambiguities

- "account" was used to mean both **Customer** and **User** — within this context, always use **Customer**. **User** belongs to the auth context.
```

## Rules

- **One glossary per bounded context.** Never create a single global glossary.
- **Be opinionated.** Pick the best term, list others as aliases to avoid.
- **Flag conflicts explicitly.** Ambiguous terms within a context get called out.
- **Keep definitions tight.** One sentence max. Define what it IS, not what it does.
- **Show relationships.** Bold term names, express cardinality where obvious.
- **Only include domain terms.** Skip generic programming concepts unless they have domain-specific meaning.
- **Map cross-boundary terms.** When a concept exists in multiple contexts, document the mapping — don't merge the definitions.
- **Write an example dialogue.** 3-5 exchanges between dev and domain expert showing terms used precisely within this context.

## Re-running

When invoked again for the same bounded context:

1. Read the existing `UBIQUITOUS_LANGUAGE.md` in that directory
2. Incorporate new terms from subsequent discussion
3. Update definitions if understanding has evolved
4. Mark changed entries with "(updated)" and new entries with "(new)"
5. Re-flag any new ambiguities
6. Update context mappings if boundary interactions changed

## Post-output instruction

After writing the file, state:

> I've written/updated `UBIQUITOUS_LANGUAGE.md` for the [context name] bounded context. From this point forward I will use these terms consistently within this context. If I drift from this language or you notice a term that should be added, let me know.
