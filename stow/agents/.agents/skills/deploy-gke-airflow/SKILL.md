---
name: deploy-gke-airflow
description: >-
  Deploy self-hosted Airflow on GKE. Build Airflow Docker image with Dagger,
  publish to GCR, update Helm values image tag, and roll out via Terragrunt.
  Triggers on: "deploy airflow", "build airflow image", "update airflow",
  "airflow image", "roll out airflow", "airflow helm", "airflow GKE".
---

# Deploy Airflow on GKE

Manual deployment workflow for the self-hosted Airflow cluster. No automated CD pipeline exists -- image builds and Helm rollouts are triggered manually.

## Architecture

- **Image**: Custom Airflow image built from `orchestrator/pyproject.toml` deps via Dagger
- **Registry**: `eu.gcr.io/ultra-acre-286807/europe-west4/airflow:<commit-sha>`
- **Infra**: Terraform + Terragrunt at `infra/gcp/eagleeye/k8s/airflow/`
- **Helm**: Official Apache Airflow chart v1.19.0, values at `infra/gcp/eagleeye/k8s/airflow/helm/values.yaml`
- **DAGs**: Deployed separately via git-sync from `deploy/airflow-dags` branch (GitHub Actions)

## When to Use

- Python dependency changes in `orchestrator/pyproject.toml` (airflow-image group)
- Helm values changes (`values.yaml` or `helm.tf` config overrides)
- Terraform changes to Airflow infra (secrets, ExternalSecrets, monitoring, network policies)

## Deployment Workflow

### Step 1: Build and Publish Image

Only needed when `orchestrator/pyproject.toml` or `uv.lock` changed. Skip to Step 2 if only Helm/Terraform config changed.

```bash
# From repo root. Fetches GCP SA key inline -- do NOT export separately.
GCP_CREDENTIALS=$(gcloud secrets versions access latest \
  --secret=cloud-build-runner-json-key --project=ultra-acre-286807) \
dagger call --progress=plain publish-airflow \
  --src=. \
  --commit-sha=$(git rev-parse --short HEAD) \
  --gcp-credentials=env:GCP_CREDENTIALS \
  > /tmp/dagger-publish-airflow.log 2>&1
```

This takes up to 30 minutes. When running via Claude Code Bash tool, use `run_in_background: true`. Read log file after completion -- the published image URI is at the end (e.g. `eu.gcr.io/ultra-acre-286807/europe-west4/airflow:7582841f6`).

### Step 2: Update Image Tag

After image is published, update the tag in `values.yaml`:

```yaml
# infra/gcp/eagleeye/k8s/airflow/helm/values.yaml line 11
defaultAirflowTag: "<new-commit-sha>"
```

Commit this change.

### Step 3: Terraform Plan and Apply

```bash
cd infra/gcp/eagleeye/k8s/airflow
terragrunt plan -out=/tmp/airflow.tfplan
```

**Never auto-approve.** Show plan to user before applying:

```bash
terragrunt apply /tmp/airflow.tfplan
```

### Step 4: Verify

```bash
kubectl -n airflow get pods
kubectl -n airflow describe pod <scheduler-pod> | grep Image:
```

## Key Files

| File | Purpose |
|------|---------|
| `orchestrator/pyproject.toml` | Airflow image deps (`airflow-image` group) |
| `uv.lock` | Locked dependency versions |
| `.cicd/src/shared/build-airflow.ts` | Dagger image build logic |
| `.cicd/src/index.ts` | `publishAirflow()` Dagger function |
| `infra/gcp/eagleeye/k8s/airflow/helm/values.yaml` | Helm values (image tag, config, env) |
| `infra/gcp/eagleeye/k8s/airflow/helm.tf` | Helm release + dynamic config overrides |
| `infra/gcp/eagleeye/k8s/airflow/secrets.tf` | GCP Secret Manager secrets |
| `infra/gcp/eagleeye/k8s/airflow/external_secrets.tf` | ExternalSecrets (GCP SM -> K8s) |

## DAG Deployment (Separate)

DAGs deploy via GitHub Actions (`.github/workflows/deploy-airflow-dags.yml`) to the `deploy/airflow-dags` branch, picked up by git-sync. DAG changes don't require an image rebuild.
