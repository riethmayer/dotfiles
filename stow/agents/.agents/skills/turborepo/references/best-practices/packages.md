# Creating Internal Packages

How to create and structure internal packages in your monorepo.

## Package Creation Checklist

1. Create directory in `packages/`
2. Add `package.json` with name and exports
3. Add source code in `src/`
4. Add `tsconfig.json` if using TypeScript
5. Install as dependency in consuming packages
6. Run package manager install to update lockfile

## Package Compilation Strategy

### Source-Level Exports (JIT) — EagleEye default (ADR-003)

All private packages export raw TypeScript. The consuming app's bundler compiles it.

```json
// packages/ui/package.json
{
  "name": "@repo/ui",
  "private": true,
  "type": "module",
  "exports": {
    "./button": { "types": "./src/button.tsx", "default": "./src/button.tsx" },
    "./card": { "types": "./src/card.tsx", "default": "./src/card.tsx" }
  },
  "scripts": {
    "typecheck": "tsc --noEmit",
    "test": "vitest run"
  }
}
```

**Why this is the default:**

- No build step — no stale `dist/` bugs
- Perfect tree-shaking — bundler sees full source graph
- Perfect source maps and go-to-definition
- Faster CI — packages only typecheck, no compilation
- Simpler config — one tsconfig mode (`noEmit: true`)

**Consumer requirements:**

- Next.js apps: `transpilePackages` in `next.config.ts`
- Node server apps: `tsup` with `noExternal: [/^@eagleeye\//]`
- Vitest: handles `.ts` natively

**Limitations:**

- No Turborepo build cache for packages (but nothing to cache — no build step)
- Consumer must use a TypeScript-aware bundler
- Can't use TypeScript `paths` (use Node.js subpath imports instead)

### Compiled (dist/) — NOT used for EagleEye packages

Only for packages published to npm (none currently). See ADR-003 for rationale.

## Defining Exports

### Multiple Entrypoints

```json
{
  "exports": {
    ".": "./src/index.ts", // @repo/ui
    "./button": "./src/button.tsx", // @repo/ui/button
    "./card": "./src/card.tsx", // @repo/ui/card
    "./hooks": "./src/hooks/index.ts" // @repo/ui/hooks
  }
}
```

### Conditional Exports (Compiled)

```json
{
  "exports": {
    "./button": {
      "types": "./src/button.tsx",
      "import": "./dist/button.mjs",
      "require": "./dist/button.cjs",
      "default": "./dist/button.js"
    }
  }
}
```

## Installing Internal Packages

### Add to Consuming Package

```json
// apps/web/package.json
{
  "dependencies": {
    "@repo/ui": "workspace:*" // pnpm/bun
    // "@repo/ui": "*"         // npm/yarn
  }
}
```

### Run Install

```bash
pnpm install  # Updates lockfile with new dependency
```

### Import and Use

```typescript
// apps/web/src/page.tsx
import { Button } from '@repo/ui/button';

export default function Page() {
  return <Button>Click me</Button>;
}
```

## One Purpose Per Package

### Good Examples

```
packages/
├── ui/                  # Shared UI components
├── utils/               # General utilities
├── auth/                # Authentication logic
├── database/            # Database client/schemas
├── eslint-config/       # ESLint configuration
├── typescript-config/   # TypeScript configuration
└── api-client/          # Generated API client
```

### Avoid Mega-Packages

```
// BAD: One package for everything
packages/
└── shared/
    ├── components/
    ├── utils/
    ├── hooks/
    ├── types/
    └── api/

// GOOD: Separate by purpose
packages/
├── ui/          # Components
├── utils/       # Utilities
├── hooks/       # React hooks
├── types/       # Shared TypeScript types
└── api-client/  # API utilities
```

## Config Packages

### TypeScript Config

```json
// packages/typescript-config/package.json
{
  "name": "@repo/typescript-config",
  "exports": {
    "./base.json": "./base.json",
    "./nextjs.json": "./nextjs.json",
    "./library.json": "./library.json"
  }
}
```

### ESLint Config

```json
// packages/eslint-config/package.json
{
  "name": "@repo/eslint-config",
  "exports": {
    "./base": "./base.js",
    "./next": "./next.js"
  },
  "dependencies": {
    "eslint": "^8.0.0",
    "eslint-config-next": "latest"
  }
}
```

## Common Mistakes

### Forgetting to Export

```json
// BAD: No exports defined
{
  "name": "@repo/ui"
}

// GOOD: Clear exports
{
  "name": "@repo/ui",
  "exports": {
    "./button": "./src/button.tsx"
  }
}
```

### Wrong Workspace Syntax

```json
// pnpm/bun
{ "@repo/ui": "workspace:*" }  // Correct

// npm/yarn
{ "@repo/ui": "*" }            // Correct
{ "@repo/ui": "workspace:*" }  // Wrong for npm/yarn!
```

### Missing from turbo.json Outputs

```json
// Package builds to dist/, but turbo.json doesn't know
{
  "tasks": {
    "build": {
      "outputs": [".next/**"]  // Missing dist/**!
    }
  }
}

// Correct
{
  "tasks": {
    "build": {
      "outputs": [".next/**", "dist/**"]
    }
  }
}
```

## TypeScript Best Practices

### Use Node.js Subpath Imports (Not `paths`)

TypeScript `compilerOptions.paths` breaks with JIT packages. Use Node.js subpath imports instead
(TypeScript 5.4+).

**JIT Package:**

```json
// packages/ui/package.json
{
  "imports": {
    "#*": "./src/*"
  }
}
```

```typescript
// packages/ui/button.tsx
import { MY_STRING } from "#utils.ts" // Uses .ts extension
```

**Compiled Package:**

```json
// packages/ui/package.json
{
  "imports": {
    "#*": "./dist/*"
  }
}
```

```typescript
// packages/ui/button.tsx
import { MY_STRING } from "#utils.js" // Uses .js extension
```

### Use `tsc` for Internal Packages

For internal packages, prefer `tsc` over bundlers. Bundlers can mangle code before it reaches your
app's bundler, causing hard-to-debug issues.

### Enable Go-to-Definition

For Compiled Packages, enable declaration maps:

```json
// tsconfig.json
{
  "compilerOptions": {
    "declaration": true,
    "declarationMap": true
  }
}
```

This creates `.d.ts` and `.d.ts.map` files for IDE navigation.

### No Root tsconfig.json Needed

Each package should have its own `tsconfig.json`. A root one causes all tasks to miss cache when
changed. Only use root `tsconfig.json` for non-package scripts.

### Avoid TypeScript Project References

They add complexity and another caching layer. Turborepo handles dependencies better.
