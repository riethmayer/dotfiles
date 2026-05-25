---
name: validate-gcp-alerts
description: >-
  Validate Cloud Monitoring alert policies by querying live metrics via Grafana MCP
  and comparing against Terraform-defined thresholds. Triggers on: "validate alerts",
  "check alerts", "are alerts firing", "test alert policies", "verify metrics",
  "alert status", "check monitoring".
---

# Validate GCP Alerts

Validates Cloud Monitoring PromQL alert policies by extracting queries from Terraform,
running them against live GMP data via Grafana MCP, and reporting status.

## Prerequisites

- Grafana MCP server connected (port-forward to localhost:3000 if behind IAP)
- Grafana datasource UID known (query `mcp__grafana__list_datasources` to find it)

## Workflow

### 1. Extract Alert Definitions

Find all `google_monitoring_alert_policy` resources with `condition_prometheus_query_language`:

```
Grep for: condition_prometheus_query_language
Path: infra/gcp/eagleeye/k8s/*/monitoring.tf
```

For each alert, extract:
- `display_name` — alert name
- `query` — the PromQL expression (contains both the metric query and threshold comparison)
- `duration` — how long the condition must hold
- `severity` — WARNING or CRITICAL
- `enabled` — whether the alert is active

Split the query into: **metric expression** (left of comparator) and **threshold** (right).
Example: `airflow_scheduler_heartbeat{namespace="airflow"} < 1` → metric: `airflow_scheduler_heartbeat{namespace="airflow"}`, op: `<`, threshold: `1`

### 2. Query Live Metrics

For each extracted metric expression, use Grafana MCP:

```
mcp__grafana__query_prometheus(
  datasourceUid: "<uid>",
  expr: "<metric expression>",  # WITHOUT the comparator/threshold
  startTime: "now",
  queryType: "instant"
)
```

### 3. Evaluate and Report

For each alert, determine status:
- **OK**: metric exists and does NOT breach threshold
- **FIRING**: metric exists and breaches threshold
- **NO DATA**: metric returns empty (scraping broken or metric doesn't exist)
- **DISABLED**: alert has `enabled = false`

Present results as a table:

| Alert | Severity | Current Value | Threshold | Status |
|-------|----------|---------------|-----------|--------|

### 4. Diagnose Issues

If NO DATA:
1. Check metric exists: `mcp__grafana__list_prometheus_metric_names` with regex
2. Check labels: `mcp__grafana__list_prometheus_label_values` for the metric
3. Check PodMonitoring target status if custom-scraped metric

If FIRING:
1. Query a 1h range to see if it's transient or sustained
2. Check the `duration` field — alert only fires after sustained breach

## GMP Metric Naming

GMP system metrics use different names and labels than standard Prometheus:

| Standard Prometheus | GMP Equivalent | GMP Labels |
|---|---|---|
| `container_cpu_usage_seconds_total` | `kubernetes_io:container_cpu_core_usage_time` | `namespace_name`, `pod_name`, `container_name` |
| `container_memory_working_set_bytes` | `kubernetes_io:container_memory_used_bytes` | `namespace_name`, `pod_name`, `container_name` |
| `node_cpu_seconds_total` | `kubernetes_io:node_cpu_core_usage_time` | `node_name` |

Custom-scraped metrics (StatsD, KEDA) keep their original names and use standard labels
(`namespace`, `pod`, `container`).
