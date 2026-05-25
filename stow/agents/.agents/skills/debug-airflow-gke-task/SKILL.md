---
name: debug-airflow-gke-task
description: >-
  Debug self-hosted Airflow tasks on GKE via Cloud Logging.
  Covers task logs, scheduler logs, and DAG processor logs.
  Survives OOMKill and spot preemption (Fluent Bit sidecar streams in real-time).
  Accepts Airflow UI URLs to extract DAG ID, run ID, and task ID.
  Triggers on: "debug airflow task", "get airflow logs", "why did this task fail",
  "check airflow task", "airflow task logs", "debug DAG run".
---

# Debug Airflow GKE Task

Debug Airflow on GKE via Cloud Logging. All file-based logs are streamed by Fluent Bit
sidecars with structured metadata (`airflow_dag_id`, `airflow_task_id`, `airflow_run_id`,
`airflow_attempt`, `airflow_log_type`). Survives OOMKill — logs are available up to ~1s
before pod death. Retention: 30 days.

## URL Parsing

Users provide Airflow UI URLs. Extract parameters from the URL:

**DAG run URL:**

```text
https://airflow.eagleeye.earlybird.com/dags/{dag_id}/grid?dag_run_id={run_id_encoded}&tab=graph
```

**Task URL:**

```text
https://airflow.eagleeye.earlybird.com/dags/{dag_id}/grid?dag_run_id={run_id_encoded}&tab=graph&task_id={task_id}
```

Extract:
- `dag_id` — from path: `/dags/{dag_id}/grid`
- `run_id` — from query param `dag_run_id`, URL-decoded (e.g., `manual__2026-04-01T12%3A26%3A49.812874%2B00%3A00` → `manual__2026-04-01T12:26:49.812874+00:00`)
- `task_id` — from query param `task_id` (optional; if absent, fetch all tasks)

## Fetching Logs

All queries use `gcloud logging read` against project `ultra-acre-286807`.
Common filter prefix for all queries:

```
resource.type="k8s_container"
resource.labels.namespace_name="airflow"
```

### Single task log

```bash
gcloud logging read '
  resource.type="k8s_container"
  resource.labels.namespace_name="airflow"
  jsonPayload.airflow_log_type="task"
  jsonPayload.airflow_dag_id="{dag_id}"
  jsonPayload.airflow_task_id="{task_id}"
  jsonPayload.airflow_run_id="{run_id}"
' --project=ultra-acre-286807 --limit=500 --freshness=24h \
  --format="value(jsonPayload.log)" --order=asc
```

Add `jsonPayload.airflow_attempt="{N}"` to narrow to a specific attempt.

### All tasks in a DAG run

```bash
gcloud logging read '
  resource.type="k8s_container"
  resource.labels.namespace_name="airflow"
  jsonPayload.airflow_log_type="task"
  jsonPayload.airflow_dag_id="{dag_id}"
  jsonPayload.airflow_run_id="{run_id}"
' --project=ultra-acre-286807 --limit=1000 --freshness=24h \
  --format="value(jsonPayload.airflow_task_id,jsonPayload.log)" --order=asc
```

### Scheduler logs

```bash
gcloud logging read '
  resource.type="k8s_container"
  resource.labels.namespace_name="airflow"
  jsonPayload.airflow_log_type="scheduler"
' --project=ultra-acre-286807 --limit=200 --freshness=1h \
  --format="value(jsonPayload.log)" --order=asc
```

### DAG processor logs

```bash
gcloud logging read '
  resource.type="k8s_container"
  resource.labels.namespace_name="airflow"
  jsonPayload.airflow_log_type="dag_processor"
' --project=ultra-acre-286807 --limit=200 --freshness=1h \
  --format="value(jsonPayload.log)" --order=asc
```

### Worker stdout/stderr (container logs)

These are shipped by the GKE node agent (not Fluent Bit) and cover Airflow's console output:

```bash
gcloud logging read '
  resource.type="k8s_container"
  resource.labels.namespace_name="airflow"
  resource.labels.container_name="worker"
' --project=ultra-acre-286807 --limit=200 --freshness=1h \
  --format="value(textPayload)" --order=asc
```

Replace `container_name="worker"` with `"scheduler"` or `"triggerer"` as needed.

## Analyzing Logs

After fetching, scan for:
- `Marking task as SUCCESS` or `Marking task as FAILED` — final status
- `ERROR` or `Exception` lines — root cause
- `INFO` lines with domain output (e.g., `BigQuery OK`, `Postgres OK`) — success confirmation
- `Killed` or `OOMKilled` — in worker stdout/stderr if task logs cut off abruptly

Present a summary table:

| Task | Status | Detail |
|------|--------|--------|
| task_name | SUCCESS/FAILED/OOMKILLED | Key output line or error message |

For failed tasks, show the full traceback.

## Debugging Decision Flow

1. **Task failed normally** → fetch task log by dag_id + task_id + run_id
2. **Task log cuts off / no "Marking task as" line** → worker was OOMKilled or preempted; check worker stdout/stderr for `Killed` signal
3. **Task never started** → check scheduler logs for parsing errors or pool starvation
4. **DAG not appearing** → check DAG processor logs for import errors
