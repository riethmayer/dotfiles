---
name: domain-architecture
description: "Use when creating, extracting, or reorganizing `packages/*` domain modules under ADR-022 ports-and-adapters boundaries."
---

# Domain Architecture

Create, extract, and maintain domain packages in `packages/` following Ports & Adapters (ADR-022).

## Decision Tree

1. **Am I creating a new domain package?** -> Use `bash .agents/skills/domain-architecture/scripts/scaffold-domain.sh <name>`
2. **Am I extracting from apps/ to packages/?** -> Read [migration-guide.md](references/migration-guide.md)
3. **Am I adding to an existing domain package?** -> Follow naming conventions below
4. **Which domain does this belong to?** -> Check [domain-map.md](references/domain-map.md)

## The 7 Domains (set in stone)

Domains are directory prefixes under `packages/`. Each use-case package lives inside its domain.

| Domain | Directory | Status | Example use-case |
|--------|-----------|--------|------------------|
| Sourcing | `packages/sourcing/` | Active | `enrich-linkedin-contact-details` |
| Screening | `packages/screening/` | Planned | `screen-company` |
| Due Diligence | `packages/due-diligence/` | Planned | `analyze-competition` |
| Closing | `packages/closing/` | Future | `prepare-ic-memo` |
| Portfolio Work | `packages/portfolio-work/` | Planned | `monitor-portfolio` |
| Follow-on Financing | `packages/follow-on-financing/` | Future | `evaluate-follow-on` |
| Exit | `packages/exit/` | Future | `calculate-returns` |

**Cross-cutting** packages live directly under `packages/`: `@eagleeye/auth`, `@eagleeye/crm`, `@eagleeye/entity-resolution`, `@eagleeye/logging`, `@eagleeye/prisma`, `@eagleeye/prompts`, `@eagleeye/sql-guardian`, `@eagleeye/taxonomy`, `@eagleeye/ux`

## Naming Conventions

**Package naming:** Always `<verb>-<noun>` — use-case centric, reveals intent at a glance:
- `enrich-linkedin-contact-details` not `enrichment-provider`
- `find-stealth-founders` not `stealth-founder-finder`
- `sync-affinity-contacts` not `affinity-contact-syncer`

**Directory layout:** `packages/<domain>/<use-case>/`

| Type | Pattern | Real example |
|------|---------|--------------|
| Port | `<use-case>.port.ts` | `enrich-linkedin-contact-details.port.ts` |
| Zod | `<use-case>.zod.ts` | `enrich-linkedin-contact-details.zod.ts` |
| Adapter | `<use-case>.<vendor>.adapter.ts` | `enrich-linkedin-contact-details.rocketreach.adapter.ts` |
| Util | `<use-case>.<vendor>.util.ts` | `enrich-linkedin-contact-details.rocketreach.util.ts` |
| Memory | `<use-case>.memory.adapter.ts` | `enrich-linkedin-contact-details.memory.adapter.ts` |
| Registry | `<use-case>.registry.ts` | `enrich-linkedin-contact-details.registry.ts` |
| Feature | `<use-case>.feature` | `enrich-linkedin-contact-details.feature` |
| Test | `*.test.ts` | `rocketreach.test.ts` |

Scanning `packages/sourcing/` lists all sourcing capabilities. Adapter filenames reveal vendor choices.

## File Roles (quick ref)

| Suffix | Purpose | Can import |
|--------|---------|------------|
| `.port.ts` | Interface only. Zero tech deps | `.zod.ts` (type-only) |
| `.zod.ts` | Zod schemas + domain types | Only Zod |
| `.adapter.ts` | Implements port with specific tech | `.port.ts` + `.zod.ts` + tech libs |
| `.util.ts` | Vendor-specific pure helpers | `.zod.ts` only |
| `.registry.ts` | Wires adapters to ports | `.port.ts` + adapters |
| `.use-case.ts` | Business logic orchestration | Registry only (never adapters directly) |
| `.feature` | Gherkin acceptance criteria (living spec) | N/A — not code |

## Reference Implementation

`@eagleeye/enrich-linkedin-contact-details` at `packages/sourcing/enrich-linkedin-contact-details/` is the canonical example. Study it before creating new packages.

```
packages/sourcing/enrich-linkedin-contact-details/
  enrich-linkedin-contact-details.feature                    # Gherkin acceptance criteria
  src/
    enrich-linkedin-contact-details.port.ts                  # EnrichmentProvider interface
    enrich-linkedin-contact-details.zod.ts                   # EnrichmentResult, EmailResult, etc.
    enrich-linkedin-contact-details.rocketreach.adapter.ts   # RocketReach API v2
    enrich-linkedin-contact-details.rocketreach.util.ts      # selectBestEmail/Phone (vendor-specific)
    enrich-linkedin-contact-details.memory.adapter.ts        # In-memory for tests
    enrich-linkedin-contact-details.registry.ts              # createRegistry(apiKey)
    linkedin-parser.ts                                       # URL extraction utility
    index.ts                                                 # Barrel export
```

**What it demonstrates:**
- Use-case centric naming: package name = `<verb>-<noun>` = capability
- Domain prefix directory: `packages/sourcing/` groups by bounded context
- Vendor-specific files: `*.rocketreach.adapter.ts` and `*.rocketreach.util.ts`
- Zod split from port: `*.zod.ts` for schemas, `*.port.ts` for interface only
- Swappable providers: same `EnrichmentProvider` port, different adapters (RocketReach today, Apollo tomorrow)

## Deep Dives

- [Domain Map](references/domain-map.md) — all 7 domains + cross-cutting with current code locations
- [Package Structure](references/package-structure.md) — file layout, exports, tsconfig
- [Ports & Adapters](references/ports-and-adapters.md) — ADR-022 patterns with real + hypothetical examples
- [Migration Guide](references/migration-guide.md) — step-by-step strangler pattern extraction
