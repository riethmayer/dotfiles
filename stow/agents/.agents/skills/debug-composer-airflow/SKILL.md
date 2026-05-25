---
name: debug-composer-airflow
description: Use when debugging a failed Airflow task instance in GCP Composer, investigating DAG run errors, or pulling task logs from Cloud Logging. Triggers on "debug this task", "why did this DAG fail", "get Airflow logs", "check task instance".
---

# Debug Composer Airflow Task Instance

Debug failed Airflow task instances in GCP Composer using Cloud Logging via gcloud CLI. No Airflow UI access required.

## Environment

- **GCP Project:** `ultra-acre-286807`
- **Composer Environment:** `eagleeye-composer-3-europe-west4`
- **Region:** `europe-west4`
- **Log ID:** `airflow-worker` (task execution logs)

## Step 1: Extract Task Details

From an Airflow UI URL, extract (URL-decode `%3A` → `:`, `%2B` → `+`):

**Grid view** (`/dags/<dag_id>/grid?...`):
- `dag_id` from the URL path: `/dags/<dag_id>/grid`
- `task_id` from `task_id=` param — **use the FULL value as-is, including any numeric suffixes like `-2`** (these are part of the task name, NOT map indices)
- `execution_date` from `dag_run_id=scheduled__<date>` — extract the date portion after `scheduled__`

**Legacy log view** (`/log?...`):
- `dag_id` from `dag_id=` param
- `task_id` from `task_id=` param
- `execution_date` from `execution_date=` param

## Step 2: Pull Logs via Cloud Logging

**Run as a background command** (logs can be large), writing to `/tmp/task_logs.txt`, then use the `Read` tool to inspect:

```bash
gcloud logging read \
  'resource.type="cloud_composer_environment"
   AND resource.labels.environment_name="<env_name>"
   AND log_id("airflow-worker")
   AND labels.workflow="<dag_id>"
   AND labels.task-id="<task_id>"
   AND labels.execution-date="<execution_date>"' \
  --project=ultra-acre-286807 \
  --limit=5000 \
  --format="value(textPayload)" \
  --order=asc > /tmp/task_logs.txt
```

Use `run_in_background: true` in the Bash tool, then `Read` the output file once complete.

### Critical Label Mapping

Cloud Logging labels differ from Airflow terminology:

| Airflow concept | Cloud Logging label |
|-----------------|---------------------|
| `dag_id` | `labels.workflow` |
| `task_id` | `labels.task-id` |
| `execution_date` | `labels.execution-date` |

### IMPORTANT: task_id is always literal

**Never split or reinterpret the task_id value.** Suffixes like `-2`, `-3` are part of the task name (e.g. dlt-generated shard names), NOT map indices. Use the exact `task_id` from the URL in `labels.task-id`.

### Other Useful Labels

From the log entries you can also filter by:
- `labels.try-number` — specific retry attempt
- `labels.worker_id` — which worker pod ran it
- `labels.map-index` — for mapped tasks (only when task uses Airflow dynamic task mapping, not for numeric task name suffixes)

## Step 3: Find Errors

Use the `Grep` tool (NOT bash grep) to search for errors in the pulled logs:

```
pattern: "error|exception|traceback|failed|CRITICAL"
path: /tmp/task_logs.txt
-i: true
output_mode: content
```

Then use `Read` tool with `offset`/`limit` to see surrounding context at relevant line numbers.

## Step 4: Investigate Root Cause

### SQLMesh Audit Failures

If you see `NodeAuditsErrors: Audits failed: <audit_name>`:

1. Find the actual SQL query in logs — search for `Executing SQL:.*<audit_name>` or `Executing SQL:.*<table_name>.*AS \`audit\``
2. The query shows the exact threshold and logic used
3. **Check SQLMesh state DB** — audit params may be stale (see edge case below)

### SQLMesh State DB Access

The state DB runs via cloud-sql-proxy in Docker:

```bash
# Find the container
docker ps --format "{{.Names}} {{.Ports}}" | grep sqlmesh

# Container: sqlmesh-state-db-proxy, port 127.0.0.1:5557
# Credentials from data/transformation/.env (run setup_local.sh if missing)
source data/transformation/.env

PGPASSWORD="$SQLMESH_STATE_DB_PASSWORD" psql \
  -h 127.0.0.1 -p 5557 -U sqlmesh -d postgres \
  -c "<query>"
```

Useful state DB queries:
```sql
-- Check audit params stored in snapshot
SELECT name, identifier,
  snapshot::jsonb->'node'->'audits' AS audits
FROM sqlmesh_state._snapshots
WHERE name LIKE '%<table>%' AND kind_name = 'EXTERNAL';

-- Check snapshot fingerprint
SELECT identifier,
  fingerprint::jsonb->'metadata_hash' AS metadata_hash,
  snapshot::jsonb->'node'->'audits' AS audits
FROM sqlmesh_state._snapshots
WHERE name = '"ultra-acre-286807"."<schema>"."<table>"';
```

## Edge Cases

### Stale Audit Parameters in State DB

**Symptom:** Audit query in logs uses a different threshold than what's in `external_models.yaml`.

**Cause:** SQLMesh snapshots are immutable. Changing audit params in YAML doesn't automatically create a new snapshot if SQLMesh doesn't detect it as a fingerprint-changing modification. The state DB retains the old snapshot with old params.

**Diagnosis:**
1. Compare the threshold in the executed SQL (from logs) vs `data/transformation/external_models.yaml`
2. Query the state DB to see what's actually stored
3. Check git history for when the param changed and whether `sqlmesh plan` was run after

**Fix:** Run `sqlmesh plan` against prod to generate new snapshots. Note: `sqlmesh plan --explain` may show "no changes" if the fingerprint algorithm doesn't consider the param change as breaking — may need to force a new snapshot.

### Log Query Returns Empty

If your Cloud Logging query returns no results:
1. Verify `execution_date` format matches exactly (including timezone `+00:00`)
2. Try broader search: drop `labels.execution-date`, use `timestamp>=` and `textPayload:"<dag_id>"` instead
3. Check `labels.try-number` — logs might be under a different retry attempt

### Multiple Docker Containers

Don't confuse containers. `docker ps` may show multiple postgres containers. The SQLMesh state DB runs via `sqlmesh-state-db-proxy` on port 5557. Other postgres containers are unrelated — always filter by name:

```bash
docker ps --format "{{.Names}} {{.Ports}}" | grep sqlmesh
```
