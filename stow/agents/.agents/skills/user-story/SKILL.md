---
name: user-story
description: Write a structured user story that map to verb-noun capabilities with Gherkin acceptance criteria. Use when capturing requirements, writing stories, defining capabilities, onboarding agents to a domain, or when someone mentions "user story", "acceptance criteria", or "capability".
---

# User Story

Write user stories as capability cards: small, structured, traceable to a `<verb>-<noun>` package.

## Card, Conversation, Confirmation

Every story has three parts:

- **Card** — just enough to identify the capability
- **Conversation** — happens in /grill-me, not captured on the card
- **Confirmation** — Gherkin scenarios that prove it works

## Card Format

```markdown
### `<verb>-<noun>`

> <one-line description of what this capability does>

**Domain:** <bounded context from domain-architecture>
**Modalities:** web | mcp | cli | slack | cron
```

The card IS the capability name. It maps 1:1 to a `packages/<domain>/<verb-noun>/` directory. The actor (investor, team member) is implicit — don't capture it on the card.

If different actors need different scopes, that's an API concern: put it in the port interface, not the story. Interfaces should be deep, not shallow and hide lots of complexity from the user.

### Naming rules

- Always `<verb>-<noun>`: `enrich-linkedin-contact-details`, `triage-stealth-founder`
- The name reveals intent at a glance
- If you can't name it `<verb>-<noun>`, the scope is wrong — split or rethink

## Confirmation Format

Write acceptance criteria as a `.feature` file **co-located in the package directory**:

```
packages/sourcing/enrich-linkedin-contact-details/
  src/
    enrich-linkedin-contact-details.port.ts
    enrich-linkedin-contact-details.zod.ts
    ...
  enrich-linkedin-contact-details.feature   ← lives here
  package.json
```

The filename matches the capability: `<verb-noun>.feature`.

```gherkin
Feature: <verb-noun capability name>
  As an <actor>
  I want a <feature>
  So that <benefit>

  Scenario: <happy path>
    Given <precondition>
    When <action through the port interface>
    Then <observable outcome>

  Scenario: <edge case or failure>
    Given <precondition>
    When <action>
    Then <expected handling>
```

### Rules for scenarios

- **Test through the port**, not the adapter — scenarios survive vendor swaps
- **Observable outcomes only** — what the caller sees, not what the database stores
- **3-5 scenarios per capability** — happy path, key edges, one failure. Not exhaustive.
- **No implementation details** — no API keys, no SQL, no retry counts in scenarios
- Keep scenarios short: 1 Given, 1 When, 1-2 Then. Use Background for shared setup.
- **Co-locate with the package** — the `.feature` file is the living spec for that capability

## Progressive Discovery

1. **Check for `domain-architecture` skill** — read its domain map to find which bounded context this belongs to
2. **Check for `UBIQUITOUS_LANGUAGE.md`** in the domain directory — use canonical terms or introduce terms if required
3. **Check existing capabilities** in `packages/<domain>/` — avoid duplication, find patterns
4. **Check Gherkin format** in @references/gherkin-format.md to structure the scenarios expressively

## Writing a Story

1. **Name the capability** — `<verb>-<noun>` that reveals intent
2. **Write the card** — one line, domain, modalities
3. **Write 3-5 Gherkin scenarios** — confirm through the port interface
4. **Check the domain map** — does this belong to an existing domain or cross-cutting?

If the domain has a `UBIQUITOUS_LANGUAGE.md`, use its terms in the scenarios. If a term is missing, flag it for addition.

## Example: Shipped Capability

```markdown
### `enrich-linkedin-contact-details`

> Look up email and phone for a LinkedIn profile via enrichment providers.

**Domain:** Sourcing
**Modalities:** web | mcp | cli
```

```gherkin
Feature: enrich-linkedin-contact-details

  Scenario: Successful enrichment
    Given a valid LinkedIn profile URL
    When I request enrichment
    Then I receive an email and phone result with status "complete"

  Scenario: Profile not found
    Given a LinkedIn URL that does not match any record
    When I request enrichment
    Then I receive a result with status "not_found"

  Scenario: Provider timeout
    Given the enrichment provider is slow
    When I request enrichment
    Then I receive a result with status "timeout"
```

## Example: Planned Capability

```markdown
### `screen-company`

> Evaluate a company against investor screening criteria and return a pass/fail with evidence.

**Domain:** Screening
**Modalities:** web | mcp
```

```gherkin
Feature: screen-company

  Scenario: Company passes screening
    Given a company profile with strong traction signals
    And screening criteria for "deep-tech pre-seed"
    When I screen the company
    Then the result is "pass" with supporting evidence

  Scenario: Company fails screening
    Given a company profile outside target geography
    And screening criteria requiring "Europe"
    When I screen the company
    Then the result is "fail" with reason "geography mismatch"

  Scenario: Insufficient data
    Given a company profile with no traction data
    When I screen the company
    Then the result is "insufficient data" listing missing signals
```

## Batching Stories

When writing multiple stories for a domain, group them under the domain heading:

```markdown
## Sourcing

### `find-stealth-founders`

> Discover pre-seed companies via career transition and research signals.

### `rank-suggestions`

> Score and order company suggestions for an investor's review queue.

### `track-signal-source`

> Attribute how a company was first discovered.
```

Then write Gherkin for each. Cards first, confirmation second — conversation happens live.
