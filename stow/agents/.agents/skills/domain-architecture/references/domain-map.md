# Domain Map

## The 7 Bounded Contexts (VC Investment Lifecycle)

### 1. Sourcing (`packages/sourcing/`)

Finding and surfacing investment opportunities.

**Current code:** `apps/eagleeye-web/src/**/list-view/`, `suggestion/`, `plugin/`
**Key entities:** SuggestedCompany, DealflowSource, Signal, SourcingCriteria

**Shipped packages:**
- `@eagleeye/enrich-linkedin-contact-details` — enrich LinkedIn profiles with email/phone via RocketReach (reference implementation for ADR-022)
- `@eagleeye/enrich-with-signals` — enrich LinkedIn profiles with EagleEye signal data (score, sector, geography) from BQ gold models
- `@eagleeye/push-stealth-lead` — push stealth founder leads to CRM (Affinity)
- `@eagleeye/review-stealth-funnel` — funnel counts, activity feed, team metrics. Extracted from `@eagleeye/stealth-review`
- `@eagleeye/review-stealth-deals` — deal listing, founder detail, cohorts. Extracted from `@eagleeye/stealth-review`
- `@eagleeye/measure-stealth-pipeline` — TTM, stage durations, conversion rates, timelines. Extracted from `@eagleeye/stealth-review`
- `@eagleeye/label-stealth-founder-industry-experience` — classify founder industry experience for stealth pipeline
- `@eagleeye/triage-stealth-founder` — triage and prioritize stealth founder leads

**Planned use cases:**
- `find-stealth-founders` — discover pre-seed companies via signals
- `rank-suggestions` — score and order suggestions for investors
- `track-signal-source` — attribute how a company was discovered

### 2. Screening (`@eagleeye/screening`)

Initial evaluation of sourced companies.

**Current code:** `apps/eagleeye-web/src/**/company-view/`, `top-organisations/`
**Key entities:** Company, CompanyProfile, ScreeningCriteria, CompanyScore
**Planned use cases:**
- `screen-company` — evaluate against investor criteria
- `compare-companies` — side-by-side comparison
- `get-company-profile` — aggregate company data for review

### 3. Due Diligence (`@eagleeye/due-diligence`)

Deep analysis of screened companies.

**Current code:** `apps/eagleeye-web/src/**/competition/`, `traction/`, `timeline/`
**Key entities:** CompetitiveLandscape, TractionMetric, TimelineEvent
**Planned use cases:**
- `analyze-competition` — map competitive landscape
- `track-traction` — monitor growth metrics
- `build-timeline` — construct company history

### 4. Closing (`@eagleeye/closing`)

Deal negotiation and closing. **Status: future domain.**

**Key entities:** Deal, TermSheet, InvestmentCommittee
**Planned use cases:**
- `prepare-ic-memo` — generate investment committee materials
- `track-deal-progress` — monitor deal pipeline stages

### 5. Portfolio Work (`@eagleeye/portfolio`)

Post-investment portfolio management.

**Current code:** `apps/eagleeye-web/src/**/dashboard/`
**Key entities:** PortfolioCompany, BoardMeeting, Reporting
**Planned use cases:**
- `monitor-portfolio` — track portfolio company health
- `prepare-board-report` — generate LP reporting

### 6. Follow-on Financing (`@eagleeye/follow-on`)

Subsequent investment rounds. **Status: future domain.**

**Key entities:** FollowOnRound, ProRataRight, Valuation
**Planned use cases:**
- `evaluate-follow-on` — assess follow-on investment opportunity
- `track-pro-rata` — manage pro-rata rights

### 7. Exit (`@eagleeye/exit`)

Portfolio company exits. **Status: future domain.**

**Key entities:** ExitEvent, ReturnMetric, ExitStrategy
**Planned use cases:**
- `track-exit-opportunity` — monitor exit windows
- `calculate-returns` — compute MOIC/IRR

## Cross-Cutting Packages

### `@eagleeye/crm` (SHIPPED — types; URGENT — Affinity adapter, license ends mid-2026)

Universal VC deal lifecycle types. Shipped at `packages/crm/`.

**Shipped entities:** CrmStatus, PipelineStage, ReviewPeriod, ReviewScope, Fund, TeamMember
**Shipped functions:** `classifyCrmStage()` — CRM status to pipeline stage mapping

CRM abstraction layer for adapters: 325+ files currently coupled to Affinity API.

**Planned entities:** Contact, Organization, Interaction, Pipeline, Field
**Adapters needed:** Affinity (current), HubSpot (planned), Memory (tests)
**Planned use cases:**
- `sync-contacts` — bidirectional CRM sync
- `log-interaction` — record investor-company touchpoints
- `manage-pipeline` — move deals through stages

### `@eagleeye/auth` (exists)

Authentication, session management, and access control. Shipped at `packages/auth/`.

**Key entities:** User, Session, Permission
**Use cases:**
- `authenticate-user` — login/session management
- `manage-preferences` — user settings
- `track-activity` — usage analytics

### `@eagleeye/entity-resolution`

Deduplication and entity matching across data sources.

**Current code:** `potential-duplicates/`, matching logic
**Key entities:** EntityMatch, MergeCandidate, MatchScore
**Use cases:**
- `find-duplicates` — identify potential duplicate entities
- `merge-entities` — combine duplicate records
- `resolve-identity` — match entities across sources

### `@eagleeye/taxonomy`

Investment categories and classification.

**Current code:** `apps/investment-thesis/`
**Key entities:** Category, Sector, SubSector, Tag
**Use cases:**
- `classify-company` — assign taxonomy categories
- `manage-categories` — CRUD for investment categories

### `@eagleeye/prisma` (exists)

Dual Prisma client (analytics + app databases).

### `@eagleeye/ux` (exists)

Shared UI component library. Shipped at `packages/ui/`.

### `@eagleeye/logging` (exists)

Structured logging. Shipped at `packages/logging/`.

### `@eagleeye/sql-guardian` (exists)

SQL query safety and validation. Shipped at `packages/sql-guardian/`.

### `@eagleeye/prompts` (in-progress — `worktree-baml-exploration` branch)

Central BAML prompt definitions with TS/Python codegen (ADR-022). Shipped at `packages/prompts/` in the baml-exploration worktree.

**Tech:** BAML (`@boundaryml/baml`) for prompt definitions, generates typed TS/Python clients.
**Shipped use cases:**
- `classify-industry` — classify founder/company industry experience via LLM (follows ADR-022 ports & adapters: port, zod, baml adapter, memory adapter, registry, thread)

**Structure:** BAML sources in `baml_src/`, generated clients in `baml_client_ts/` and `baml_client_py/`.

## Dependency Rules

```
Domains can depend on:
  - Cross-cutting packages (crm, entity-resolution, taxonomy, user, prisma)
  - Other domains ONLY through their ports (never adapters)

Cross-cutting packages can depend on:
  - @eagleeye/prisma
  - Other cross-cutting packages through ports

Never:
  - Circular dependencies
  - apps/ importing from other apps/
  - Direct adapter imports across package boundaries
```

## Design Decisions

1. CRM owns universal deal lifecycle primitives (Stage, Period, Scope, Fund, TeamMember)
2. Sourcing use cases are separate packages with verb+noun naming (e.g. `review-stealth-funnel`)
3. API surface must be intention-revealing for LLM/MCP/CLI consumption
4. Factory registry pattern per ADR-022 (not global singletons)
5. Each sourcing package is independently consumable across modalities (web, MCP, CLI, Slack)
