---
name: trpc-tanstack-nextjs
description: |
  Use when changing tRPC routers/procedures, context/auth wiring, or TanStack Query
  behavior in repo Next.js apps.
---

# tRPC + TanStack Query (Repo Specific)

Use this skill to keep API layer patterns coherent across apps with different routing generations.

## Repo Context

- Legacy Pages Router + tRPC API route pattern exists in:
  - `apps/eagleeye-web`
- App Router + tRPC route handler pattern exists in:
  - `apps/investment-thesis`
- Shared expectations:
  - strict server-side auth checks in tRPC context
  - typed routers/procedures
  - predictable client cache invalidation patterns

## Workflow

1. Detect target app and route generation (Pages vs App Router).
2. Apply matching tRPC integration pattern for that app.
3. Keep auth/session extraction inside tRPC context creation.
4. Update router/procedure contracts and client usages together.
5. Validate with target app typecheck and affected route smoke checks.

## App-Specific Guidance

- For `apps/eagleeye-web`, preserve existing Pages Router integration unless task explicitly migrates it.
- For `apps/investment-thesis`, preserve App Router route-handler integration.
- When adding new tRPC-enabled apps, default to App Router patterns unless a legacy constraint exists.

## TODO (Repo Migration)

- TODO: Rewrite `apps/eagleeye-web` toward App Router-focused tRPC integration and deprecate legacy Pages Router API wiring.

## Trigger Checklist

Use this skill when the request includes:

1. Adding/updating routers, procedures, or middleware
2. Context/auth integration with NextAuth in tRPC
3. Client query/mutation cache semantics
4. Migration planning between routing generations
