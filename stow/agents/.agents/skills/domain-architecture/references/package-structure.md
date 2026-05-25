# Package Structure

## File Layout

Packages live under domain-prefixed directories: `packages/<domain>/<use-case>/`.

```
packages/<domain>/<use-case>/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts                                       # Barrel export
│   ├── <use-case>.port.ts                             # Interface (zero tech deps)
│   ├── <use-case>.zod.ts                              # Zod schemas (domain types)
│   ├── <use-case>.registry.ts                         # Wiring (adapter -> port)
│   ├── <use-case>.<vendor>.adapter.ts                 # Vendor-specific adapter
│   ├── <use-case>.<vendor>.util.ts                    # Vendor-specific helpers (optional)
│   ├── <use-case>.memory.adapter.ts                   # In-memory adapter for tests
│   └── *.test.ts                                      # Co-located tests
```

**Real example** (`packages/sourcing/enrich-linkedin-contact-details/`):

```
packages/sourcing/enrich-linkedin-contact-details/
├── package.json                                        # @eagleeye/enrich-linkedin-contact-details
├── tsconfig.json
├── src/
│   ├── index.ts
│   ├── enrich-linkedin-contact-details.port.ts         # EnrichmentProvider interface
│   ├── enrich-linkedin-contact-details.zod.ts          # EnrichmentResult, EmailResult, etc.
│   ├── enrich-linkedin-contact-details.registry.ts     # createRegistry(apiKey)
│   ├── enrich-linkedin-contact-details.rocketreach.adapter.ts  # RocketReach API v2
│   ├── enrich-linkedin-contact-details.rocketreach.util.ts     # selectBestEmail/Phone
│   ├── enrich-linkedin-contact-details.memory.adapter.ts       # In-memory for tests
│   ├── linkedin-parser.ts                              # URL extraction utility
│   ├── linkedin-parser.test.ts
│   └── rocketreach.test.ts
```

## package.json

Subpath exports expose each architectural layer independently. Consumers import only what they need.
**All private packages export raw `.ts` source — no build step, no `dist/` (ADR-003).**

```json
{
  "name": "@eagleeye/<use-case>",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "typecheck": "tsc --noEmit",
    "test": "vitest run"
  },
  "exports": {
    ".":                  { "types": "./src/index.ts", "default": "./src/index.ts" },
    "./port":             { "types": "./src/<use-case>.port.ts", "default": "./src/<use-case>.port.ts" },
    "./zod":              { "types": "./src/<use-case>.zod.ts", "default": "./src/<use-case>.zod.ts" },
    "./registry":         { "types": "./src/<use-case>.registry.ts", "default": "./src/<use-case>.registry.ts" },
    "./adapters/<vendor>": { "types": "./src/<use-case>.<vendor>.adapter.ts", "default": "./src/<use-case>.<vendor>.adapter.ts" },
    "./adapters/memory":  { "types": "./src/<use-case>.memory.adapter.ts", "default": "./src/<use-case>.memory.adapter.ts" }
  },
  "dependencies": { "zod": "^3.24.0" },
  "devDependencies": {
    "@eagleeye/tsconfig": "workspace:*",
    "typescript": "^5.7.0",
    "vitest": "^3.0.0"
  }
}
```

**Notes:**
- `"type": "module"` — ESM package declaration
- `./port` — consumers depend only on interface (no adapter leak)
- `./zod` — import domain types without pulling in adapters
- `./adapters/<vendor>` — explicit vendor choice at import site
- `./adapters/memory` — test adapter for consumer tests
- Source TypeScript directly (no build step) — consuming apps handle compilation
- No `build`, `clean`, or `dist/` — packages only typecheck and test

**Consumer requirements:**
- Next.js apps: add package to `transpilePackages` in `next.config.ts`
- Node server apps: use `tsup` with `noExternal: [/^@eagleeye\//]` to bundle workspace imports
- Vitest: handles `.ts` imports natively

## tsconfig.json

Packages only typecheck — no compilation, no `dist/` output (ADR-003).

```json
{
  "extends": "@eagleeye/tsconfig/base.json",
  "compilerOptions": {
    "module": "esnext",
    "moduleResolution": "bundler",
    "noEmit": true
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules", "src/**/*.test.ts"]
}
```

## vitest.config.ts

```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    include: ['__tests__/**/*.test.ts'],
  },
})
```

## index.ts (Public API)

```typescript
// Re-export types from port
export type { SourcingPort, SuggestedCompany, SourcingCriteria } from './sourcing.port'

// Re-export registry (the entry point for consumers)
export { createSourcingRegistry, type SourcingRegistry } from './sourcing.registry'

// Re-export schemas for validation
export { suggestedCompanySchema, sourcingCriteriaSchema } from './sourcing.port'
```

**Rules:**
- Never export adapters from index.ts
- Export types from port, factory from registry
- Consumers use: `import { createSourcingRegistry } from '@eagleeye/sourcing'`

## How Adapters Register

The registry is a factory that wires adapters to ports:

```typescript
// sourcing.registry.ts
import type { SourcingPort } from './sourcing.port'
import { PrismaSourcingAdapter } from './sourcing.prisma.adapter'

export type SourcingRegistry = {
  sourcing: SourcingPort
}

export function createSourcingRegistry(deps: {
  prisma: PrismaClient
}): SourcingRegistry {
  return {
    sourcing: new PrismaSourcingAdapter(deps.prisma),
  }
}
```

Consumers in apps:

```typescript
// apps/eagleeye-web/src/server/registries.ts
import { createSourcingRegistry } from '@eagleeye/sourcing'
import { prisma } from '@eagleeye/prisma/client'

export const registries = {
  ...createSourcingRegistry({ prisma }),
}
```
