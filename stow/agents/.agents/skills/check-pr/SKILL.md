---
name: check-pr
description: >-
  End-to-end PR review loop: sync, fix CI, address CodeRabbit/human comments,
  push, wait for CI + CodeRabbit re-review, repeat until green.
  Triggers on: "check pr", "review pr", "fix pr", "address review",
  "review coderabbit", "review claude", "pr feedback".
---

# Check PR — Full Review & Closure Loop

Review → fix → push → wait for CI + CodeRabbit re-review → repeat until green.

## GitHub PR Feedback Model

| Abstraction | What it is | How to fetch |
|---|---|---|
| **Issue comment** | Top-level on Conversation tab | REST `issues/{n}/comments` |
| **Review** | Formal verdict (approve/request-changes/comment) | REST `pulls/{n}/reviews` |
| **Review comment** | Inline comment on diff line, belongs to a review | REST `pulls/{n}/comments` (flat list, numeric IDs) |
| **Review thread** | Thread of review comments + replies. Has `isResolved`/`isOutdated` | **GraphQL only** via `./scripts/gh-pr-threads.sh` |

Key rules:
- REST `pulls/{n}/comments` and GraphQL `reviewThreads` contain the **same inline comments**. GraphQL groups them into threads with `isResolved`/`isOutdated`. Prefer GraphQL.
- **Do NOT fetch** `pulls/$PR/comments` separately — `gh-pr-threads.sh` returns the same data with better structure.
- Issue comments are flat (no threading). Review threads have nested replies.

### gh-pr-threads.sh output schema

```json
[{
  "id": "PRRT_kwDO...",           // GraphQL thread ID — use for resolveReviewThread mutation
  "isResolved": false,
  "isOutdated": false,
  "path": "src/foo.ts",
  "line": 42,
  "comments": [{
    "id": "PRRC_kwDO...",         // GraphQL comment node ID — NOT usable for REST replies
    "author": "coderabbitai",
    "body": "...",
    "createdAt": "2026-..."
  }]
}]
```

### ID types — critical distinction

| ID source | Format | Use for |
|---|---|---|
| `gh-pr-threads.sh` thread `.id` | `PRRT_kwDO...` (GraphQL node ID) | `resolveReviewThread` mutation |
| `gh-pr-threads.sh` comment `.id` | `PRRC_kwDO...` (GraphQL node ID) | **CANNOT use for REST replies** |
| REST `pulls/{n}/comments` `.id` | Numeric (e.g., `3016687662`) | Reply via REST `comments/{id}/replies` |

To reply to a thread AND resolve it, you need **both**: the numeric REST comment ID (for the reply) and the GraphQL thread ID (for the resolve mutation). Fetch REST comment IDs with:

```bash
gh api repos/$OWNER_REPO/pulls/$PR/comments --paginate \
  --jq '.[] | {id: .id, path: .path, line: .line, body: .body[:80]}'
```

Match REST comments to GraphQL threads by `path` + `line` + `body` prefix.

## Resolve PR Number

1. Skill arguments contain a number or URL → extract PR number
2. No argument → `gh pr view --json number -q .number`
3. No PR for branch → stop

## Step 0: Sync + Conflict Gate

```bash
gh pr view $PR --json baseRefName,headRefName,mergeable,mergeStateStatus
```

If `mergeable` is `CONFLICTING`: resolve conflicts, commit, push, restart from Step 1.

Merge base branch if PR is behind:
```bash
git fetch origin $(gh pr view $PR --json baseRefName -q .baseRefName)
git merge origin/$(gh pr view $PR --json baseRefName -q .baseRefName) --no-edit
```

## Step 1: Gather PR State

```bash
OWNER_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

# PR metadata + CI + draft state
gh pr view $PR --json title,state,isDraft,baseRefName,headRefName,reviewDecision,mergeable,mergeStateStatus,statusCheckRollup,reviews,body

# Reviews with verdicts
gh api repos/$OWNER_REPO/pulls/$PR/reviews \
  --jq '.[] | {id: .id, author: .user.login, state: .state, body: .body[:200], submitted: .submitted_at}'

# Issue-level comments (top-level conversation, NOT inline code comments)
gh api repos/$OWNER_REPO/issues/$PR/comments --paginate

# Review threads — primary source for inline code feedback
./scripts/gh-pr-threads.sh $PR

# REST comment IDs — needed for replying (see ID types section above)
gh api repos/$OWNER_REPO/pulls/$PR/comments --paginate \
  --jq '.[] | {id: .id, path: .path, line: .line, body: .body[:80]}'
```

### Reading thread bodies

Thread content is in `.comments[0].body`, NOT in a top-level `.body` field. The body often contains `<details>` blocks with CodeRabbit's analysis chain — the actionable conclusion follows the last `</details>`. Extract bold `**headings**` for quick triage.

### Staleness detection

Use `isOutdated` from GraphQL thread data (set by GitHub when underlying code changes):
- **`isOutdated: true`** → code changed since comment; verify with skepticism
- **`isOutdated: false`** → comment still applies to current code

CodeRabbit never updates or resolves its own comments after pushes — treat all `isOutdated` CodeRabbit threads as likely stale.

## Step 2: CI Status

| Check | Status | Duration |
|-------|--------|----------|
| name  | pass/fail/pending | Xs |

If failing, read logs: `gh run view $RUN_ID --log-failed`

### CI fix loop

Auto-fix if possible (lint, format, typecheck, test). Max **3 attempts**.
Do not fix environmental failures (missing secrets, infra, flaky services).

### Pre-existing failures

Before spending time fixing CI failures:

1. Check if the failing file was touched by the PR: `gh pr diff $PR --name-only`
2. If not in the diff → pre-existing
3. Pre-existing in **same app/package** → auto-fix in separate commit
4. Pre-existing in **unrelated apps** → report to user, do not fix

### Push resilience

- Use `git push --force-with-lease` after rebase/amend (never bare `--force`)
- If pre-push hooks fail on unrelated packages, use `--no-verify` and document why

## Step 3: Categorize Comments

For each unresolved thread (`isResolved: false`), classify:

- **Blocking** — must fix before merge
- **Nitpick** — style, naming, minor improvements
- **Question** — needs clarification (draft reply, ask user before posting)
- **Stale** — `isOutdated: true` or code changed/removed
- **Praise** — no action

**Trust weighting:** Human reviewers > CodeRabbit. CodeRabbit frequently hallucinates line numbers, ticket references, and code patterns. Always verify against actual code.

## Step 3b: Self-Review — Pedantic Cleanup

Before addressing reviewer comments, self-review the full diff:

1. **Dead code** — unused imports, variables, config, functions
2. **Spotted improvements** — fix if <5 min, within PR scope
3. **Missing tests** — new public functions or behavior changes without coverage
4. **Cascading dead references** — check callers when removing types/options

Mandatory. Do not skip even if reviewers haven't flagged these.

## Step 4: Verify Then Address

For each unresolved finding:

1. Read actual code at the referenced lines — does the problem exist?
2. **Valid** → fix code
3. **Stale/Invalid/Hallucinated** → reply explaining why, then resolve

### Replying to a thread

```bash
# COMMENT_ID = numeric REST ID (from pulls/{n}/comments, NOT from gh-pr-threads.sh)
gh api repos/$OWNER_REPO/pulls/$PR/comments/$COMMENT_ID/replies \
  -f body="Explanation of why this is invalid / what was fixed."
```

### Resolving a thread

```bash
# THREAD_ID = GraphQL node ID from gh-pr-threads.sh `.id` field (PRRT_kwDO...)
gh api graphql \
  -f query='mutation($t: ID!) { resolveReviewThread(input: {threadId: $t}) { thread { isResolved } } }' \
  -f t="$THREAD_ID"
```

If you only need to resolve without replying (e.g., outdated/stale threads), skip the reply and just resolve.

Fix valid findings without asking. Group related fixes per file.

## Step 5: Local CI Gate, Commit & Push

**Before pushing**, run local CI:

```bash
lefthook run ci-js --no-auto-install
```

For Python changes, also: `lefthook run ci-python --no-auto-install`

Fix failures before committing. Then:
1. Stage changed files
2. Commit: `fix: address PR review feedback` with body listing fixes
3. Push (pull first to avoid conflicts)

## Step 6: Wait for CI + CodeRabbit Re-review

After every push:

1. **Poll CI** (max 3 polls, 30s/60s/120s backoff): `gh pr checks $PR`
2. **Wait 3 minutes** for CodeRabbit
3. **Re-fetch threads**: `./scripts/gh-pr-threads.sh $PR`
4. **New unresolved items** → back to Step 3
5. **All green** → Step 7
6. **Max 5 iterations** → report remaining, stop

### Completion condition

All of:
- No unresolved threads (excluding `isResolved: true`)
- CI passing (or only environmental/flaky failures)
- `reviewDecision` is not `CHANGES_REQUESTED`
- `mergeable` is not `CONFLICTING`

## Step 7: Final Status

```bash
gh pr checks $PR
gh pr view $PR --json mergeable,mergeStateStatus,reviewDecision,isDraft
```

### Transition to ready

If draft and all checks pass: `gh pr ready $PR` (with user confirmation only).

### Request re-review

If blocking comments were addressed:
```bash
gh pr view $PR --json reviews \
  --jq '[.reviews[] | select(.state == "CHANGES_REQUESTED") | .author.login] | unique[]'
gh pr edit $PR --add-reviewer $REVIEWER
```

### Recommended next action

- **Merge** — all green, no unresolved comments
- **Wait for CI** — checks still pending
- **Request re-review** — blocking feedback addressed
- **Mark ready** — draft PR, all work complete
- **Manual intervention** — environmental failures or unresolvable conflicts
