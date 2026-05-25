# Migration Guide: Extract Domain from apps/ to packages/

## Strategy: Strangler Fig Pattern

Don't rewrite — gradually extract. Old code keeps working while new domain package grows.

## Step-by-Step

### 1. Scaffold the Package

```bash
bash .agents/skills/domain-architecture/scripts/scaffold-domain.sh <domain-name>
```

### 2. Define the Port

Start with the interfaces. Look at current code to understand what operations exist.

```bash
# Find all operations for the domain
rg "prisma\.(suggestedOrganisation|organisation)" apps/eagleeye-web/src --type ts -l
```

Extract the interface:
- Each Prisma query becomes a port method
- Each API call becomes a port method
- Return types become domain types (Zod schemas), not Prisma models

### 3. Create the Prisma Adapter

Implement the port by moving existing Prisma queries into the adapter:
- Copy queries from tRPC routes
- Map Prisma models to domain types
- Keep the same behavior, just relocated

### 4. Create the Memory Adapter

Implement the port with in-memory storage:
- Simple Maps/Arrays for storage
- Add `seed()` and `reset()` helpers
- This enables fast, isolated tests

### 5. Write Use Cases

Extract business logic from tRPC routes into use cases:
- Each tRPC procedure's logic becomes a use-case function
- Use cases receive the registry, not raw adapters
- Keep orchestration logic, move infrastructure to adapters

### 6. Wire the Registry

Create the registry factory that connects adapters to ports.

### 7. Integrate Back into the App

Update tRPC routes to use the domain package:

```typescript
// BEFORE (in tRPC route)
const suggestions = await prisma.suggestedOrganisation.findMany({ ... })

// AFTER (in tRPC route)
import { registries } from '../registries'
const suggestions = await findSuggestions(registries, criteria)
```

### 8. Write Tests

Test use cases with the memory adapter:
- Fast (no DB)
- Isolated (no shared state)
- Deterministic (controlled data)

### 9. Remove Old Code

Once the new package is wired in and tested:
- Delete the old inline logic from tRPC routes
- Remove unused Prisma imports
- Clean up any feature flags

## Backward Compatibility

During migration, keep both paths working:

```typescript
// Feature flag for gradual rollout (optional)
const useNewDomain = process.env.USE_DOMAIN_PACKAGES === 'true'

if (useNewDomain) {
  return findSuggestions(registries, criteria)
} else {
  return legacyFindSuggestions(prisma, criteria)
}
```

## Checklist: Domain Extraction Complete

- [ ] Port defined with all operations
- [ ] Prisma adapter implements port
- [ ] Memory adapter implements port
- [ ] Registry wires adapter to port
- [ ] Use cases extracted from tRPC routes
- [ ] Tests pass with memory adapter
- [ ] App routes updated to use domain package
- [ ] Old inline code removed
- [ ] No direct Prisma imports in use cases
- [ ] Package exports only types + registry factory

## Common Pitfalls

**Don't extract too much at once.** Start with one port method, one use case. Get it working end-to-end, then expand.

**Don't leak Prisma types.** Domain types (Zod schemas) are the contract. Adapters map to/from Prisma models internally.

**Don't skip the memory adapter.** It's what makes testing fast and reliable. Without it, you're just reorganizing code without gaining testability.

**Don't import adapters in use cases.** Always go through the registry. This is the key discipline that enables swapping implementations.
