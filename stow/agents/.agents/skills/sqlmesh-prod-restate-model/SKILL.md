---
name: sqlmesh-prod-restate-model
description: |
  Use when restating (backfilling/refreshing) SQLMesh data models via gcloud CLI.
  Triggers on: "restate model", "backfill model", "refresh model", "rerun sqlmesh",
  "full refresh", "restate downstream", "restate upstream".
---

# SQLMesh Model Restate via Composer

Trigger a manual restate (backfill/full refresh) of SQLMesh models in production Composer.

## Environment

- **Composer:** `eagleeye-composer-3-europe-west4`
- **Location:** `europe-west4`
- **DAG:** `sqlmesh_run`
- **GCP Project:** `ultra-acre-286807`

## Workflow

### Step 1: Find the model

Models live in `data/transformation/models/`. Search by keyword:

```bash
find data/transformation/models -name '*.sql' -not -path '*/unused/*' | xargs grep -l '<keyword>'
```

Or list all models in a layer:

```bash
ls data/transformation/models/{bronze,silver,gold,pii,stg}/**/*.sql
```

Model names follow pattern: `<layer>.<source>_<entity>` (e.g., `gold.stealth_founder_attribution`).

### Step 2: Check model kind

Read the MODEL header of the `.sql` file. Look for the `kind` declaration:

| Kind | Restate behavior |
|------|-----------------|
| `INCREMENTAL_BY_UNIQUE_KEY` | Rebuilds full table (no time range) |
| `INCREMENTAL_BY_TIME_RANGE` | Rebuilds specified date range |
| `FULL` | Always rebuilds entirely |
| `VIEW` | Recreates view (instant) |
| `SCD_TYPE_2_BY_COLUMN` | Rebuilds full history |

**Check for `forward_only TRUE`** inside the `kind` block. Forward-only models normally only process new intervals. Restating them forces a full rebuild — this is intentional and safe, but be aware it overwrites existing data.

### Step 3: Ask user about scope

Present these options:

1. **This model + downstream** (default) — `--restate-model "schema.model_name"` — downstream always cascades automatically
2. **This model + upstream + downstream** — `--restate-model "+schema.model_name"` (prefix `+` includes upstream; downstream still cascades)

**Note:** `--restate-model` always cascades downstream — there is no way to restate a single model in isolation with this flag.

### Step 4: Build the gcloud command

#### Dry run first (recommended)

```bash
gcloud composer environments run eagleeye-composer-3-europe-west4 \
  --project=ultra-acre-286807 \
  --location=europe-west4 \
  dags trigger -- sqlmesh_run \
  --conf '{"dry_run": true, "models": ["<schema.model_name>"]}'
```

#### Production run

```bash
gcloud composer environments run eagleeye-composer-3-europe-west4 \
  --project=ultra-acre-286807 \
  --location=europe-west4 \
  dags trigger -- sqlmesh_run \
  --conf '{"dry_run": false, "models": ["<schema.model_name>"]}'
```

#### Multiple models

```bash
gcloud composer environments run eagleeye-composer-3-europe-west4 \
  --project=ultra-acre-286807 \
  --location=europe-west4 \
  dags trigger -- sqlmesh_run \
  --conf '{"dry_run": false, "models": ["bronze.harmonic_companies", "silver.harmonic_companies_act"]}'
```

#### With upstream (`+` prefix)

```bash
--conf '{"dry_run": false, "models": ["+gold.stealth_founder_attribution"]}'
```

### Step 5: Verify execution

Use the **`debug-composer-airflow`** skill to pull task logs and investigate results. The relevant task ID is `manual_restate`.

## How the DAG works

The `sqlmesh_run` DAG (`orchestrator/dags/dwh/transformation/sqlmesh_run.py`) has a branch:

- If `models` param equals the placeholder default → routes to `janitor → run` (regular scheduled path)
- If `models` param is customized → routes to `manual_restate` task

The `manual_restate` task builds: `sqlmesh plan --auto-apply --restate-model <model1> --restate-model <model2> ...`

Non-production environments force dry-run regardless of the `dry_run` param.

## Common restate scenarios

| Scenario | Models to restate |
|----------|------------------|
| Ingestion backfill landed | Bronze model for that source |
| Logic change deployed | The changed model (downstream auto-cascades) |
| Seed data updated | The seed model + downstream |
| Full pipeline refresh | Top-level bronze models (everything cascades) |
| Single gold table stale | The specific gold model |
