---
name: ship
description: >-
  Autonomous PR merge and deploy. Runs /check-pr until green,
  squash-merges, monitors Cloud Run deployment and Sentry errors.
  Triggers on: "ship it", "ship this PR", "merge and deploy",
  "ship to production", "deploy this".
---

# Ship — Autonomous Merge & Deploy

Runs `/check-pr` → squash-merge → monitor deployment. Fully autonomous once invoked.

## Resolve PR

1. `$ARGUMENTS` contains PR number/URL → extract it
2. No argument → `gh pr view --json number -q .number`
3. No PR → stop

## Step 1: Run /check-pr

Invoke `/check-pr` for the PR. This handles:
- Sync with base branch
- Fix CI failures
- Address all review comments
- Wait for CodeRabbit re-review
- Repeat until green

If `/check-pr` exits with remaining items that need human input, report and stop.

## Step 2: Squash Merge

Once `/check-pr` confirms all green:

```bash
gh pr merge $PR --squash --auto
```

If `--auto` fails (e.g. branch protection requires approval), fall back to:
```bash
gh pr merge $PR --squash
```

After merge, update PR body with ship report (see below).

## Step 3: Monitor Deployment

Deployments trigger automatically on merge to master via Cloud Build.

### 3a. Watch build

```bash
# Find the build triggered by our merge commit
MERGE_SHA=$(gh pr view $PR --json mergeCommit -q .mergeCommit.oid)

# List recent builds, find ours
gcloud builds list --region=europe-west4 --limit=5 \
  --format='table(id,status,startTime,source.repoSource.commitSha)'

# Stream build logs
gcloud builds log $BUILD_ID --region=europe-west4 --stream
```

If no build triggers within 2 minutes, check if the PR's changed files match
the Cloud Build trigger path filters. Report if the change doesn't trigger a deploy.

### 3b. Verify revision

After build succeeds:

```bash
# Check new revision is serving
gcloud run revisions list --service=time-to-meeting --region=europe-west4 --limit=3

# Verify traffic is 100% on latest
gcloud run services describe time-to-meeting --region=europe-west4 \
  --format='value(traffic)'
```

### 3c. Check health

```bash
# Recent errors in Cloud Run logs (last 5 minutes)
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=time-to-meeting AND severity>=ERROR AND timestamp>=\"$(date -u -v-5M '+%Y-%m-%dT%H:%M:%SZ')\"" \
  --limit=20 --format='table(timestamp,severity,textPayload)'

# Quick smoke test
curl -sf -o /dev/null -w '%{http_code}' https://ttm.eagleeye.earlybird.com/
```

### 3d. Sentry check

Check for new errors after deploy using the Sentry MCP:
- Search for issues created after merge timestamp
- Filter by `time-to-meeting` project
- Report any new error spikes

If Sentry MCP is unavailable:
```bash
# Check via sentry-cli if available
sentry-cli issues list --project=time-to-meeting --query="is:unresolved firstSeen:>1h" 2>/dev/null || true
```

## Step 4: Ship Report

Update PR body with deployment status between markers:

```markdown
<!-- ship-report-start -->
## Ship Report (auto-generated)

**Merged**: commit abc1234 via squash
**Build**: SUCCESS (Build ID: xxx, 2m 15s)
**Revision**: time-to-meeting-00042-abc serving 100% traffic
**Health**: 200 OK on https://ttm.eagleeye.earlybird.com/
**Sentry**: no new errors in 5 min post-deploy

### Review findings addressed
- Fixed lint error in `src/foo.ts` (CodeRabbit nitpick)
- Dismissed stale comment on removed function (CodeRabbit)
<!-- ship-report-end -->
```

Read current body, replace between markers (or append if missing), write back:
```bash
gh pr view $PR --json body -q .body  # read
gh pr edit $PR --body "..."          # write
```

## Guardrails

- **Pull before push** — abort if upstream has unexpected changes
- **No force push** — always regular push
- **Global timeout** — max 45 minutes wall-clock for entire flow
- **Build failure** — report and stop, do not retry deploys
- **Traffic rollback** — if errors spike post-deploy, report but do not auto-rollback (human decision)

## Multi-Service Awareness

The deploy monitoring commands above use `time-to-meeting` as default. For other services,
adapt the service name based on which app the PR changes:

| App path | Cloud Run service | Domain |
|----------|-------------------|--------|
| `apps/time-to-meeting/` | `time-to-meeting` | `ttm.eagleeye.earlybird.com` |
| `apps/investment-thesis/` | `investment-thesis` | TBD |
| `apps/eagleeye-web/` | N/A (Vercel) | `app.eagleeye.earlybird.com` |

If the PR doesn't touch any app with a deploy trigger, skip Steps 3-4 and just report the merge.
