---
name: data-platform-sqlmesh-dlt
description: |
  Use when working on dlt ingestion or SQLMesh transformation workflows, including
  audits, freshness checks, and deployment/plan/run flows.
---

# Data Platform (SQLMesh + dlt)

End-to-end ingestion/transformation conventions. Read the relevant AGENTS.md before making changes:

| Scope | Reference |
|-------|-----------|
| Architecture & quick start | `data/AGENTS.md` |
| dlt sources & config | `data/ingestion/AGENTS.md` |
| SQLMesh models & CLI | `data/transformation/AGENTS.md` |
| Naming conventions | `data/transformation/models/AGENTS.md` |
| Reusable packages | `data/packages/AGENTS.md` |
| dlt extension / DAG factory | `data/packages/dlt_extension/AGENTS.md` |
| Troubleshooting | `data/transformation/TROUBLESHOOTING.md` |

## How SQLMesh Works (Mental Model)

### Tables are outputs of scheduled processes

Every BigQuery table you query is the output of a scheduled process with a specific `cron`. It is NOT a static snapshot. When comparing data between environments or between a model and its source, the first question is always: **when was each table last refreshed and what cron does it run on?**

### Environments = physical snapshots + virtual views

BigQuery datasets (`bronze`, `silver`, `gold`) contain **views** pointing to physical tables in `sqlmesh__<layer>`. Each physical table is a **snapshot** — a versioned copy tied to a specific model definition.

- **Production:** views in `gold.*` point to production snapshots. The `prod` prefix is omitted from dataset names.
- **Dev environments:** `gold_dev_nikita.*` views point to the *same* production snapshots for unchanged models, and new snapshots only for changed models. No redundant backfill.
- **PR environments:** `gold_eagleeye_<PR#>.*` — created by CI, same mechanics. **Not backfilled** (cost savings) — structural validation only.

This means concurrent developers never clash — each gets isolated snapshots.

### Fingerprint = model identity

The physical table name includes a hash (e.g., `stealth_review_funnel__3130667810`). This hash is the model's **fingerprint** — derived from its SQL body, config, cron, and dependencies. **Any change to any of these — even just adding `cron '@hourly'` — produces a different fingerprint → a separate physical table.**

Consequences for dev environments:
- If your branch changes a model's fingerprint (even metadata-only), dev gets its **own physical table** with an **independent refresh lifecycle**.
- That dev table is only refreshed when YOU run `sqlmesh run` or `sqlmesh plan --restate-model`. Production's hourly/daily scheduler does NOT refresh dev physical tables.
- Upstream models with changed fingerprints also get separate dev tables — the entire downstream chain diverges.

### Statefulness and intervals

SQLMesh tracks state in a **separate Postgres DB** (not BigQuery — BQ lacks transactions). Once an interval is computed for ANY model kind (FULL or incremental), it **cannot be recomputed** without explicit restatement. `sqlmesh run` only processes **pending** intervals — it is a no-op for already-computed intervals. The `@start_ts` / `@end_ts` variables represent the current interval boundaries.

**To refresh already-computed data:** use `--restate-model` or invalidate + recreate the environment. `sqlmesh run` alone will NOT re-materialize.

### Breaking changes and backfill

Any change to the SQL body of a model = **breaking change** → SQLMesh drops the old snapshot and backfills from scratch. This is safe for most models but dangerous for tables that store `CURRENT_TIMESTAMP()` or similar runtime values — backfill overwrites history.

**Use `forward_only true`** on models where preserving historical data matters (e.g., attribution timestamps). Changes propagate only from the next scheduled run — no backfill.

Adding a new column to a forward-only table puts NULLs in existing rows. Edge cases exist — be careful.

## Gotchas

1. **`sqlmesh plan` = plan AND apply in one command.** There is no separate `apply`. Use `--no-prompts --auto-apply` for non-interactive execution. `--no-prompts` alone skips categorization prompts but still asks for backfill confirmation — `--auto-apply` is needed to skip that too. Don't confuse it with Terraform's separate `plan`/`apply`.
2. **Must run from correct project path.** Always use `uv run sqlmesh -p data/transformation <cmd>`. Running without `-p` from repo root creates config in the wrong place and models become invisible.
3. **PR environments are NOT backfilled.** They validate structure only. To test data, use your personal dev environment (`dev_<username>`).
4. **SQLMesh bot doesn't regenerate on new commits.** Plan is generated on PR open/first push. If you push again, verify the bot's plan diff still matches your latest changes.
5. **Prefer SQL over Python models.** Python models have serialization constraints (no loggers, frozensets, StrEnum at module level; cross-class references break). Only use Python when you must call an API.
6. **Environment TTL is 7 days.** Unused dev/PR environments are garbage-collected after 7 days of no state changes.
7. **Counter of shame** (`data/transformation/README.md`): when production has drift (deployed code doesn't match state), bump the counter to create a deploy-only PR.
8. **`sqlmesh run` does NOT re-materialize computed intervals.** This applies to FULL models too. If data is stale, use `--restate-model` or invalidate + recreate the environment.
9. **Dev data drift ≠ SQL bug.** When dev and prod data differ, check cron schedules first. A model on `@daily` in prod vs `@hourly` in dev (or vice versa) will naturally diverge between refresh cycles. Compare cron schedules and last refresh times BEFORE diffing SQL logic.

## Development Workflow

The inspection loop — validate before persisting, because intervals are one-way:

```
plan --explain -vv  →  render  →  query (ee-sql)  →  plan (apply)
   what + why         exact SQL    validate output     persist + done
                                                          ↓
                                                   interval is DONE
                                                   no --force flag
                                                          ↓
                                                   recovery = restate
                                                   (can be expensive)
```

### 1. Make changes

Edit models in `data/transformation/models/<layer>/<source>/`. If relying on new external tables, add them to `external_models.yaml` with freshness audits (mandatory — either provide audit or explicitly ignore).

### 2. Inspect the plan (without applying)

```bash
uv run sqlmesh -p data/transformation plan dev_<username> --no-prompts --skip-tests --explain -vv
```

Shows full diff with reasoning — what changed, why each model is categorized. **Does not apply.**

### 3. Render compiled SQL

```bash
uv run sqlmesh -p data/transformation render <layer>.<model_name>
```

For incremental models, render with concrete time bounds:
```bash
uv run sqlmesh -p data/transformation render <layer>.<model_name> --start 2025-02-23 --end 2025-02-24
```

### 4. Validate output before persisting

Run the rendered SQL ad-hoc to check results:
- **BQ Console:** paste and run
- **CLI:** use `/query-ee-database` skill — `ee_sql.py bq --read-only=true -q "<rendered SQL> LIMIT 20"`

**Why this matters:** SQLMesh is stateful — once an interval is processed, it cannot be reprocessed without `--restate-model`, which for `INCREMENTAL_BY_UNIQUE_KEY` rebuilds the **entire** table. Render+query is the safety net before a one-way operation.

### 5. Lint and format

```bash
uv run sqlmesh -p data/transformation format
```

### 6. Apply to dev environment

```bash
uv run sqlmesh -p data/transformation plan dev_<username> --no-prompts --auto-apply --skip-tests
```

`--no-prompts` skips categorization prompts, `--auto-apply` skips the backfill `y/n` confirmation. Both are needed for fully non-interactive execution.

### 7. Targeted runs

Run a specific model and its upstream only:
```bash
uv run sqlmesh -p data/transformation run --select-model <layer>.<model_name>
```

Local restatement (drop + rebuild):
```bash
uv run sqlmesh -p data/transformation plan dev_<username> --restate-model <layer>.<model_name>
```

### 8. Clean up between workstreams

```bash
uv run sqlmesh -p data/transformation invalidate dev_<username> --sync
```

### 9. Push PR and review CI

CI creates PR environment + checks:
- Linter, formatting, unit tests
- **Prod plan preview** — shows exact changes that will deploy to production, including drift ("counter of shame" in `data/transformation/README.md`)

### 10. Deploy

Comment `/sqlmesh/deploy` on the PR. Bot deploys and closes PR on success.

## Debugging Data Drift Between Environments

When dev and prod show different numbers, follow this order — **operational checks before SQL logic**:

1. **Check cron schedules.** Compare the model's `cron` in your branch vs production (master). A changed cron changes the fingerprint → separate physical table → independent refresh lifecycle.
2. **Check fingerprints.** Query `INFORMATION_SCHEMA.VIEWS` for both environments to see if they point to the same physical table (`sqlmesh__<layer>.<model>__<hash>`). Different hash = different data.
3. **Check upstream fingerprints.** If the model's own fingerprint matches but data differs, check whether upstream models have diverged fingerprints for the same reasons.
4. **Check last refresh time.** The physical table reflects data as of its last `sqlmesh run`. If production refreshed at 3 AM and dev refreshed at 2 PM, any upstream data ingested between those times (e.g., hourly Affinity) causes expected drift.
5. **Only then** compare SQL logic between branch and master.

## Workflow

1. Identify whether change is ingestion, transformation, or both.
2. Apply source/model changes with existing naming and dedupe patterns.
3. Run validation commands (format, lint, render) before deployment.
4. Use SQLMesh planning and audit-gated execution consistently.
5. Confirm schedule/cadence interactions for related pipelines.

## Guardrails

- Do not bypass audit-gate behavior for production-intended changes.
- Keep incremental cursor and deduplication logic consistent.
- Preserve naming and environment conventions in SQLMesh config.
- Prefer small-scoped changes with explicit model/resource impact.
- External model freshness: binary choice — provide audit OR explicitly ignore. No third option.

## Schema Contract Violations

When a dlt pipeline fails with `contract_mode=freeze` (column or data type violation), use the **dlt-schema-drift-fix** skill for step-by-step remediation — patching both BigQuery and `_dlt_version` schema registry.

## Trigger Checklist

Use this skill when the request mentions:

1. SQLMesh plans/runs/deployments or model edits
2. dlt source/resource additions or ingestion schedule changes
3. Audit/freshness checks and gating logic
4. Data pipeline incidents tied to ingestion/transformation boundaries
5. Schema contract violations → defer to **dlt-schema-drift-fix** skill
