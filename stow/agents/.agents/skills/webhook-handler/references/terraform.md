# Terraform Patterns

Patterns for adding webhook infrastructure in `infra/gcp/eagleeye/apps/webhooks_server/`.

## Add Pub/Sub topic

In `pubsub.tf`, add a module block using `pubsub_bq_ingestion`:

```hcl
module "{source}_webhook_events" {
  source = "../../../_modules/pubsub_bq_ingestion"

  project_id  = var.project_id
  topic_name  = "webhooks-{source}"
  bq_table_id = "${var.project_id}.raw.${google_bigquery_table.webhook_events.table_id}"
  labels      = local.labels
}
```

Creates: main topic, dead-letter topic, BigQuery subscription to `raw.webhook_events`, IAM bindings.

## Add secret (HMAC only)

In `service_account.tf`, add a secret module:

```hcl
module "{source}_webhook_secret" {
  source = "../../../_modules/secret"
  name   = "{source}-webhook-secret"
  labels = local.labels
  sa_emails_to_grant_access = [
    module.webhooks_server_sa.sa_email,
  ]
}
```

## Mount secret in Cloud Run (HMAC only)

In `cloud_run.tf`, add env var inside the container template:

```hcl
env {
  name = "{SOURCE}_WEBHOOK_SECRET" # pragma: allowlist secret
  value_source {
    secret_key_ref {
      secret  = "{source}-webhook-secret"
      version = "latest"
    }
  }
}
```

## Apply workflow

Auto-execute from `infra/gcp/eagleeye/apps/webhooks_server/`:

```bash
terragrunt plan    # review output
terragrunt apply   # apply after review
```

If Cloud Run fails on first apply due to IAM propagation delay on new secrets, re-run plan+apply.

## Set secret value (HMAC only)

Confirm with user before executing:

```bash
# Generate and store secret
openssl rand -hex 32 | gcloud secrets versions add {source}-webhook-secret --data-file=-

# Force Cloud Run to pick up the new secret
gcloud run services update webhooks-server --region=europe-west4 --update-labels=restart=$(date +%s)
```
