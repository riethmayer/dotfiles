---
name: next-drizzle-apps
description: |
  Use when changing schema, migrations, queries, or auth-aware data access in
  `apps/time-to-meeting` or `apps/investment-thesis`.
---

# Next + Drizzle Apps

Use this skill to keep the smaller Next.js apps consistent on schema, query, and runtime patterns.

## Repo Scope

- `apps/time-to-meeting`
- `apps/investment-thesis`

## Workflow

1. Update schema first (`src/db/schema.ts`) and keep relations explicit.
2. Update queries and server procedures that depend on changed fields.
3. Run the correct migration/generation command for the target app.
4. Verify auth-aware query paths (session email/user role checks).
5. Run targeted typecheck/test before broad repo commands.

## Data and Auth Boundaries

- Keep DB access in server-side modules, not client components.
- Prefer typed query outputs instead of ad-hoc casting.
- Keep auth checks near query boundaries for protected paths.
- Avoid app drift: reuse shared auth utilities where possible.

## Trigger Checklist

Use this skill when the task includes:

1. Drizzle schema or migration edits in either app
2. Next route/server code that reads/writes via Drizzle
3. Data model changes tied to auth/session behavior
4. Consistency work between the two smaller Next apps
