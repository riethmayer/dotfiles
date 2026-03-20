# Gherkin Reference

## Structure

Every `.feature` file follows this hierarchy:

```
Feature
  Rule (optional, groups scenarios under a business rule)
    Background (optional, shared Given steps)
    Scenario
      Given / When / Then / And / But
```

## Keywords

### Feature

Top-level container. One per file. Free-form description underneath.

```gherkin
Feature: enrich-linkedin-contact-details
  Look up email and phone for a LinkedIn profile
  via enrichment providers.
```

### Rule

Groups scenarios that illustrate one business rule. Optional.

```gherkin
Feature: triage-stealth-founder

  Rule: Founders with recent funding signals are deprioritized

    Scenario: Recently funded founder
      Given a founder who raised a seed round last month
      When I triage the founder
      Then the founder is marked "deprioritized"
```

### Background

Shared preconditions for all scenarios in a Feature or Rule. Runs before each scenario.

```gherkin
Background:
  Given screening criteria for "deep-tech pre-seed in Europe"
```

Keep it short (1-3 lines). If it scrolls off screen, use higher-level steps.

### Scenario

One concrete example. Synonym: `Example`.

```gherkin
Scenario: Company passes screening
  Given a company profile with strong traction signals
  When I screen the company
  Then the result is "pass" with supporting evidence
```

### Steps

| Keyword | Purpose | Think of it as |
|---------|---------|----------------|
| `Given` | Set up initial state | Precondition (past tense) |
| `When` | Trigger an action | The event |
| `Then` | Assert an outcome | Observable result |
| `And` | Continue previous keyword | Readability sugar |
| `But` | Continue with negation | Readability sugar |
| `*` | Bullet-point style | For lists |

Steps are matched by their text, not their keyword — `Given X` and `Then X` with identical text are duplicates.

### Scenario Outline

Run the same scenario with different data. Use `< >` parameters and an `Examples` table.

```gherkin
Scenario Outline: Enrichment status mapping
  Given a LinkedIn profile that returns <provider_status>
  When I request enrichment
  Then I receive a result with status "<expected_status>"

  Examples:
    | provider_status | expected_status |
    | found           | complete        |
    | no_match        | not_found       |
    | timed_out       | timeout         |
```

## Step Arguments

### Data Tables

Pass structured data to a step:

```gherkin
Given the following screening criteria:
  | field      | value          |
  | geography  | Europe         |
  | stage      | pre-seed       |
  | sector     | deep-tech      |
```

### Doc Strings

Pass multi-line text. Delimited by `"""` or `` ``` ``:

```gherkin
Given a company description:
  """
  Building next-generation quantum error correction
  for fault-tolerant computation at room temperature.
  """
```

## Tags

Prefix with `@`. Place above Feature, Rule, or Scenario.

```gherkin
@sourcing @wip
Feature: find-stealth-founders
```

## Best Practices

- **1 Given, 1 When, 1-2 Then** per scenario — keep it tight
- **Describe behaviour, not implementation** — no API keys, SQL, or vendor names in scenarios
- **Use domain language** — terms from UBIQUITOUS_LANGUAGE.md
- **3-5 scenarios per feature** — happy path, key edges, one failure
- **Background for shared setup** — but keep it under 4 lines
- **Scenario Outline for data variations** — avoid copy-paste scenarios
