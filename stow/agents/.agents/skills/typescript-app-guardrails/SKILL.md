---
name: typescript-app-guardrails
description: Use when editing TypeScript in this monorepo to run high-signal app checks before merge; default TS skill for feature and bugfix work.
---

# TypeScript App Guardrails

Default TypeScript quality gate for day-to-day app work in this repo.

Treat this as the default TS skill. Only escalate to specialized TS skills when this gate cannot resolve the issue.

## Trigger

Use when changes touch `.ts` or `.tsx` in `apps/*` or `packages/*`, especially:

- `apps/eagleeye-web`
- `apps/time-to-meeting`
- `apps/investment-thesis`
- `packages/auth`
- `packages/prisma`

## High-Signal Checks

1. Boundary typing: no unbounded `any` at API, DB, parser, or external-service boundaries.
2. Exhaustiveness: discriminated unions and `never` checks for variant logic.
3. Null safety: explicit handling for nullable and optional values.
4. React correctness: no derived state in `useEffect`; no direct state mutation.
5. Data ownership: do not copy query/server data into local state unless editing requires a local buffer.
6. Contract sync: when changing route or tRPC types, update server and callers in the same change.
7. Export preservation: after linter/formatter reformats a file, verify all named exports still exist — reformatters can silently drop exports, breaking downstream imports.
8. React compiler: `useEffect(() => setState(x), [])` triggers react-compiler warning — wrap in `startTransition`: `useEffect(() => startTransition(() => setState(x)), [])`.

## Linter Reformat Safety

When a linter or formatter rewrites an entire file (tabs→spaces, quote style, etc.), it can silently drop or corrupt code. After any whole-file reformat:

1. Run `git diff <file>` and check for removed exports, props, or function signatures
2. Verify all `export function` and `export const` declarations still exist
3. Check that component prop types haven't lost properties
4. If the file has downstream importers, run `pnpm typecheck` on the consuming app

## Escalate Only When Needed

- Advanced type-level utility design that crosses package boundaries -> `domain-architecture`
- React or Next.js framework-specific behavior -> `next-best-practices`
- tRPC integration behavior -> `trpc-tanstack-nextjs`

## Expected Output

Return only:

- `Blockers` (must fix before merge)
- `Risks` (should fix)
- `Pass` (no findings)
