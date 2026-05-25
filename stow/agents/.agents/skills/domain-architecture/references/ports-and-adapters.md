# Ports & Adapters (ADR-022)

## Core Principle

Business logic depends on **interfaces** (ports), never on **implementations** (adapters). This allows swapping infrastructure without touching business logic.

```text
Use Case -> Port (interface) <- Adapter (implementation)
```

## Reference Implementation (shipped)

`@eagleeye/enrich-linkedin-contact-details` — the first package built with this pattern. Read these files as the canonical example:

**Port** (`enrich-linkedin-contact-details.port.ts`):
```typescript
import type { EnrichmentResult } from './enrich-linkedin-contact-details.zod.js'

export interface EnrichmentProvider {
  lookup(linkedinUrl: string): Promise<EnrichmentResult | null>
}

export const INTER_LOOKUP_DELAY_MS = 4_000
```

**Zod schemas** (`enrich-linkedin-contact-details.zod.ts`):
```typescript
import { z } from 'zod'

export const EnrichmentResultSchema = z.object({
  status: z.enum(['complete', 'not_found', 'error', 'timeout']),
  error: z.string().optional(),
  sourceId: z.number().optional(),
  email: z.object({
    email: z.string().email(),
    emailType: z.enum(['professional', 'personal']),
    emailGrade: z.string(),
  }).optional(),
  phone: z.object({
    phone: z.string().min(1),
    phoneType: z.string(),
  }).optional(),
})

export type EnrichmentResult = z.infer<typeof EnrichmentResultSchema>
```

**Adapter** (`enrich-linkedin-contact-details.rocketreach.adapter.ts`):
```typescript
import type { EnrichmentProvider } from './enrich-linkedin-contact-details.port.js'

// Factory function — returns the port interface, hides all RocketReach specifics
export function rocketReachEnricher(apiKey: string): EnrichmentProvider {
  return {
    async lookup(linkedinUrl) {
      // RocketReach API calls, polling, retry — all hidden behind the port
    },
  }
}
```

**Registry** (`enrich-linkedin-contact-details.registry.ts`):
```typescript
import type { EnrichmentProvider } from './enrich-linkedin-contact-details.port.js'
import { rocketReachEnricher } from './enrich-linkedin-contact-details.rocketreach.adapter.js'

export interface EnrichmentRegistry { enricher: EnrichmentProvider }

export function createRegistry(apiKey: string): EnrichmentRegistry {
  return { enricher: rocketReachEnricher(apiKey) }
}
```

**Consumer** (`apps/slack-bot/src/app.ts`):
```typescript
import { rocketReachEnricher } from '@eagleeye/enrich-linkedin-contact-details/adapters/rocketreach'

const enricher = rocketReachEnricher(config.rocketReachApiKey)
app.message(/linkedin\.com\/in\//, createEnrichHandler(enricher))
```

Key patterns demonstrated:
- Port is one interface + one constant — minimal surface
- Zod schemas in separate file, imported by port via type-only
- Adapter is a factory function (not a class) returning the port interface
- Vendor-specific helpers (`*.rocketreach.util.ts`) stay within the adapter boundary
- Consumer imports from `./adapters/rocketreach` — vendor choice is explicit at the call site
- Swapping to Apollo = write `enrich-linkedin-contact-details.apollo.adapter.ts`, change one import

---

## Hypothetical Examples

## Port: Define the Contract

A port is a TypeScript interface + Zod schemas. Zero infrastructure dependencies.

```typescript
// crm.port.ts
import { z } from 'zod'

// --- Schemas ---

export const contactSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email().optional(),
  organizationId: z.string().optional(),
  fields: z.record(z.unknown()),
})

export type Contact = z.infer<typeof contactSchema>

export const interactionSchema = z.object({
  id: z.string(),
  contactId: z.string(),
  type: z.enum(['email', 'meeting', 'call', 'note']),
  date: z.date(),
  summary: z.string(),
})

export type Interaction = z.infer<typeof interactionSchema>

export const dealSchema = z.object({
  id: z.string(),
  name: z.string(),
  amount: z.number().optional(),
  stage: z.string(),
  contactId: z.string().optional(),
  expectedCloseDate: z.date().optional(),
})

export type Deal = z.infer<typeof dealSchema>

// --- Port ---

export interface CrmPort {
  // Contacts
  getContact(id: string): Promise<Contact | null>
  findContacts(query: string): Promise<Contact[]>
  upsertContact(contact: Omit<Contact, 'id'>): Promise<Contact>

  // Interactions
  getInteractions(contactId: string): Promise<Interaction[]>
  logInteraction(interaction: Omit<Interaction, 'id'>): Promise<Interaction>

  // Pipeline
  getDeals(filters?: { stage?: string }): Promise<Deal[]>
  moveDeal(dealId: string, stage: string): Promise<Deal>
}
```

**Rules for ports:**
- Only `zod` as dependency (for schemas)
- No Prisma, no HTTP, no filesystem, no database types
- Interface methods return domain types, not ORM models
- Use Zod schemas for validation at boundaries

## Adapter: Implement the Contract

An adapter implements a port using a specific technology.

### Affinity Adapter (current CRM)

```typescript
// crm.affinity.adapter.ts
import type { CrmPort, Contact, Interaction } from './crm.port'

export class AffinityCrmAdapter implements CrmPort {
  constructor(private apiKey: string, private baseUrl: string) {}

  async getContact(id: string): Promise<Contact | null> {
    const res = await fetch(`${this.baseUrl}/persons/${id}`, {
      headers: { Authorization: `Bearer ${this.apiKey}` },
    })
    if (!res.ok) return null
    const data = await res.json()
    return this.mapToContact(data)
  }

  async findContacts(query: string): Promise<Contact[]> {
    // Affinity-specific search logic
  }

  // ... other methods

  private mapToContact(affinityPerson: unknown): Contact {
    // Map Affinity API response to domain Contact type
  }
}
```

### Memory Adapter (for tests)

```typescript
// crm.memory.adapter.ts
import type { CrmPort, Contact, Interaction } from './crm.port'

export class MemoryCrmAdapter implements CrmPort {
  private contacts: Map<string, Contact> = new Map()
  private interactions: Map<string, Interaction[]> = new Map()

  async getContact(id: string): Promise<Contact | null> {
    return this.contacts.get(id) ?? null
  }

  async findContacts(query: string): Promise<Contact[]> {
    return [...this.contacts.values()].filter(c =>
      c.name.toLowerCase().includes(query.toLowerCase())
    )
  }

  async upsertContact(contact: Omit<Contact, 'id'>): Promise<Contact> {
    const id = crypto.randomUUID()
    const created = { ...contact, id }
    this.contacts.set(id, created)
    return created
  }

  // ... other methods

  // Test helpers
  seed(contacts: Contact[]) {
    contacts.forEach(c => this.contacts.set(c.id, c))
  }

  reset() {
    this.contacts.clear()
    this.interactions.clear()
  }
}
```

### Prisma Adapter (for DB-backed domains)

```typescript
// sourcing.prisma.adapter.ts
import type { PrismaClient } from '@eagleeye/prisma/app'
import type { SourcingPort, SuggestedCompany } from './sourcing.port'

export class PrismaSourcingAdapter implements SourcingPort {
  constructor(private prisma: PrismaClient) {}

  async getSuggestions(criteria: SourcingCriteria): Promise<SuggestedCompany[]> {
    const rows = await this.prisma.suggestedOrganisation.findMany({
      where: { /* map criteria to Prisma where */ },
      include: { organisation: true },
    })
    return rows.map(this.mapToSuggestedCompany)
  }

  private mapToSuggestedCompany(row: unknown): SuggestedCompany {
    // Map Prisma model to domain type
  }
}
```

## Registry: Wire It Together

```typescript
// crm.registry.ts
import type { CrmPort } from './crm.port'
import { AffinityCrmAdapter } from './crm.affinity.adapter'
import { MemoryCrmAdapter } from './crm.memory.adapter'

export type CrmRegistry = {
  crm: CrmPort
}

export function createCrmRegistry(config: {
  affinityApiKey: string
  affinityBaseUrl: string
}): CrmRegistry {
  return {
    crm: new AffinityCrmAdapter(config.affinityApiKey, config.affinityBaseUrl),
  }
}

// For tests
export function createTestCrmRegistry(): CrmRegistry & {
  crm: MemoryCrmAdapter
} {
  const crm = new MemoryCrmAdapter()
  return { crm }
}
```

## Use Case: Orchestrate Business Logic

```typescript
// sync-affinity-contacts.use-case.ts
import type { CrmRegistry } from '../crm.registry'

export async function syncAffinityContacts(
  registry: CrmRegistry,
  options: { since?: Date } = {}
): Promise<{ synced: number; errors: string[] }> {
  const { crm } = registry
  const contacts = await crm.findContacts('')
  // Business logic here — no infrastructure knowledge
  return { synced: contacts.length, errors: [] }
}
```

## Test: Use Memory Adapter

```typescript
// sync-affinity-contacts.test.ts
import { describe, it, expect, beforeEach } from 'vitest'
import { MemoryCrmAdapter } from '../src/crm.memory.adapter'
import { syncAffinityContacts } from '../src/use-cases/sync-affinity-contacts.use-case'

describe('syncAffinityContacts', () => {
  let crm: MemoryCrmAdapter

  beforeEach(() => {
    crm = new MemoryCrmAdapter()
  })

  it('syncs all contacts', async () => {
    crm.seed([
      { id: '1', name: 'Alice', fields: {} },
      { id: '2', name: 'Bob', fields: {} },
    ])

    const result = await syncAffinityContacts({ crm })
    expect(result.synced).toBe(2)
    expect(result.errors).toHaveLength(0)
  })
})
```

## Import Rules (enforced by hook)

```text
.port.ts     -> ONLY zod
.adapter.ts  -> its .port.ts + tech libs (Prisma, fetch, etc.)
.registry.ts -> .port.ts + .adapter.ts files
.use-case.ts -> .registry.ts ONLY (never .adapter.ts)
.test.ts     -> .memory.adapter.ts + .use-case.ts
```
