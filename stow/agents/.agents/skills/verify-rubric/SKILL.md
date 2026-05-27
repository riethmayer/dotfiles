---
name: verify-rubric
description: |
  Run the EagleEye verification baseline (ADR-026 + ADR-028) against the working
  tree before claiming done, committing, pushing, merging, or saying "looks good".
  Looks up the tier of changed paths from tiers.yml, runs only the dimensions
  required for that tier (D1 type+lint, D2 architecture, D3 logging, D4 contracts,
  D5 smoke boot, D6 prohibited tools), and surfaces one structured PASS/FAIL line
  per dimension with the command and exit code. **Invoke whenever you are about
  to wrap up a coding change in the EagleEye monorepo** — even when the user
  hasn't asked for verification explicitly, even when you "already ran some
  checks", even when the change feels small. Triggers on "/verify-rubric",
  "verify rubric", "rubric check", "ready to push", "ready to merge", "done",
  "looks good", "I'm finished", "checks?", "what should I run?", and any moment
  the agent is about to claim a change is complete. Use proactively at agent
  turn-end. Distinct from the Claude Code built-in `/verify` (runtime
  observation by launching the app) — this skill is the mechanical
  pre-completion rubric. Sits alongside `eagleeye-verification-gate` — this
  skill is the ADR-026-aligned successor; prefer it when both could apply.
---

# /verify-rubric — EagleEye Verification Baseline

Mechanical pre-completion gate per **[ADR-026](docs/decisions/architecture/ADR-026-agent-verification-loops/README.md)**
(six change-layer dimensions × per-tier requiredness) composed with
**[ADR-028](docs/decisions/architecture/ADR-028-verification-baseline/README.md)**
(runtime-layer observability posture).

Every dimension is an exit code. No LLM-as-judge. If you can't run the command,
report skip — never report pass.

## When to invoke

Run before any of these:

1. Saying "done", "fixed", "passing", "looks good", "ready to merge", "all set".
2. `git commit` / `git push` / `gh pr merge`.
3. Closing out a task the user delegated.
4. Asking the user "anything else?" after a coding change.

Re-invoke after every push that touches code (CI's bot-review loop counts as
"another change"). One invocation per agent turn — do not chain.

## Escape hatch

Per ADR-026 §3, set `CLAUDE_BYPASS_VERIFY=1` in the environment to skip /verify
output. The user is acknowledging they understand the risk. Print a one-line
notice and continue:

```
verify: bypassed (CLAUDE_BYPASS_VERIFY=1)
```

Do **not** auto-bypass on your own. Bypass is a user decision, not yours.

## The six dimensions (ADR-026 rubric.md)

Every dimension is binary (0 = pass, non-zero = fail) and backed by an
existing exit code. Path filters per ADR-026 §2.

| # | Name | Command | Pass condition |
|---|---|---|---|
| D1 | Type + lint clean | `mise run typecheck && lefthook run ci-js --no-auto-install && lefthook run ci-python --no-auto-install` | All three exit zero |
| D2 | Architecture boundaries | (inside `ci-js`) `architecture-eslint`, `architecture-depcruise` | Both exit zero on changed paths |
| D3 | Logging contract | (inside `ci-js`) `fallow-logging`; plus `no-console` ESLint rule (EAG-980, lands with runtime layer M2) | No findings related to `@eagleeye/logging` or `console.*` in `apps/**/src/**` |
| D4 | Data-contract parity | `mise run contracts:check` | Generated contracts match SQLMesh gold models |
| D5 | Smoke boot | `dagger call verify-baseline --app <changed-app>` (runtime layer EAG-996); today's bridge: the `Docker Image Verify (Dagger)` job in `.github/workflows/apps-pr.yml` | Built image boots, hits health path, Sentry-init asserted |
| D6 | Prohibited-tool clean | `scripts/lefthook/check-prohibited-tools.sh` | No `bq query`, `psql`, bare `python`/`pip`/`pipx` in the diff |

Run python tests via `lefthook run ci-python` only when the diff touches
Python (`*.py`, `pyproject.toml`, `uv.lock`, `data/**`, `services/**`,
`infra/**/python/**`). Pure JS/TS diffs skip D1's Python leg.

D2 is satisfied automatically once D1's `ci-js` passes — they share the
linter pass. Report D2 separately so the source of a failure is greppable.

D5 has a **path filter** (ADR-026 §2): fires only when the diff changes
`apps/<app>/src/**`, `apps/<app>/Dockerfile`, `apps/<app>/package.json`, or
any `packages/<dep>` imported by the app. README-only or `docs/**`-only diffs
do **not** trigger D5.

D6 today runs only at pre-commit. Re-run it explicitly: stage your changes
first (`git add` the files), then `lefthook run pre-commit --no-auto-install`.

## Tier lookup

Tier registry: `docs/decisions/architecture/ADR-026-agent-verification-loops/tiers.yml`
(migrating to `docs/observability/tiers.yml` per ADR-028 §1 with the first
implementation PR — try the new path first, fall back to the old).

```bash
# Where the registry lives today
TIERS_FILE=$(
  test -f docs/observability/tiers.yml && echo docs/observability/tiers.yml \
  || echo docs/decisions/architecture/ADR-026-agent-verification-loops/tiers.yml
)
```

To resolve the tier of a change:

1. Get the diff's changed paths: `git diff --name-only $(git merge-base HEAD origin/master)..HEAD`
   (or `git diff --name-only --cached` for staged-only when used pre-commit).
2. For each path that matches `apps/<name>/...`, look up `apps.<name>.tier`
   in the registry.
3. If no path matches `apps/<name>/...`, the change is **library/infra-only**.
   Use tier **`library`** — D1, D2, D3, D6 required; D5 not applicable.
4. **Multi-tier rule (ADR-026 rubric §Composition)**: highest tier dominates
   the whole PR. T1 > T2 > T3 > library > untiered.
5. **`untiered`** apps (admin, pulse, skills-registry, eagleeye-web): run
   D1, D2, D6; report D3/D4/D5 as advisory. Surface a one-line nudge that
   the app needs classification (ADR-026 §6).
6. **`excluded`** apps (firstlook, linkedin-plugin-crawler): report
   "verify: skipped — app excluded from tiering" and exit.

## Per-tier required dimensions (ADR-026 rubric.md)

| Dimension | T1 | T2 | T3 | library | untiered |
|---|---|---|---|---|---|
| D1 type+lint | **required** | **required** | **required** | **required** | **required** |
| D2 architecture | **required** | **required** | **required** | **required** | **required** |
| D3 logging | **required** | **required** | advisory | **required** | advisory |
| D4 contracts | **required** | conditional¹ | advisory | conditional¹ | advisory |
| D5 smoke boot | **required** | advisory² | n/a | n/a | advisory |
| D6 prohibited | **required** | advisory | **required** | **required** | **required** |

¹ Required when diff touches `packages/contracts`, `packages/db`, or `data/transformation/**`.

² Starts advisory due to cold-cache flakiness (~5% per the May 2026
observability report). Promote to required once retro shows <2% across two
consecutive weeks.

**Gate decision**: AND across required dimensions. A single failed required
dimension blocks the claim of "done" regardless of others. Score
(`passed_required / total_required`) is reported for trend analysis only —
never used to override a failed required dimension. 5/6 still blocks.

## Composition with runtime telemetry / observability (ADR-028)

"Telemetry" is the umbrella; this rubric only gates on **runtime telemetry**
(the slice consumed by oncall: Sentry errors, structured pino logs, uptime,
Cloud Run health). **Product telemetry** (PostHog `posthog.capture` events
for activation + retention) is consumed by product / growth and is **not
gated by D1–D6 today** — it's a separate axis. If a future rubric gates on
product-telemetry coverage, it'll land as its own ADR (and its own
dimensions), not as a stretch of D3.

The change layer (this skill) scores **what's about to land**. The runtime
layer scores **the deployed app's posture**. They compose at the report
level — observability is **advisory** until `docs/observability/scores.yml`
exists.

```bash
SCORES_FILE=docs/observability/scores.yml
if [ -f "$SCORES_FILE" ]; then
  # Surface the app's current observability score next to the change verdict.
  # Composition rule (ADR-026 §5): a T1 change must not lower the score.
  echo "observability: ${TIER} app ${APP} score=$(yq ".apps.${APP}.score" $SCORES_FILE)/5"
else
  echo "observability advisory: pending docs/observability/scores.yml (ADR-028 §1) — runtime posture not gated yet"
fi
```

Until `scores.yml` ships, always print the "pending" line so the reader
knows composition is deliberately deferred, not forgotten.

## Output contract

Print **one block per invocation**, in this exact shape. Never summarize as
"all good" without command evidence.

```
═══ /verify ═══════════════════════════════════════════════════════════
diff base:    <merge-base sha>..HEAD  (N files, M lines)
resolved app: <app>  →  tier <T1|T2|T3|library|untiered|excluded>
required:     D1 D2 ... (per tier)
advisory:     D3 D4 ...

  D1 type+lint        ✓ PASS   mise run typecheck (exit 0, 41s)
  D1 type+lint (ci)   ✓ PASS   lefthook run ci-js (exit 0, 53s)
  D2 architecture     ✓ PASS   (covered by ci-js)
  D3 logging          ✓ PASS   fallow-logging (exit 0)
  D4 contracts        ⊘ SKIP   not applicable — no packages/contracts in diff
  D5 smoke boot       ✗ FAIL   docker-verify (exit 1, see job 77909305911)
  D6 prohibited       ✓ PASS   check-prohibited-tools.sh (exit 0)

observability:        advisory — pending docs/observability/scores.yml

verdict:              ✗ BLOCKED — D5 failed (required for T1)
score:                4/5 required

next:                 Inspect docker-verify logs and re-run /verify
═══════════════════════════════════════════════════════════════════════
```

Verdict states:

- **✓ READY** — all required dimensions PASS. Safe to claim done / push / merge.
- **✗ BLOCKED — D<n> failed (required for <tier>)** — at least one required
  dimension failed. Name the failing dimension(s) explicitly.
- **⊘ DEFERRED — <reason>** — verify couldn't run (e.g. dirty working tree,
  missing branch, hooks not installed). Treat as fail-closed: do not claim done.

Status glyphs:

- `✓ PASS` — exit 0 and not skipped.
- `✗ FAIL` — non-zero exit.
- `⊘ SKIP` — not applicable for the tier or diff. State **why** it doesn't apply.
- `⊝ ADVISORY` — ran, surfaced findings, but didn't gate. Use for advisory
  dimensions on the tier.

Never print `✓ PASS` without an exit code (or `(covered by ci-js)` for D2).
"All good" with no command output is the failure mode ADR-026 was written
against — see AGENTS.md citing Syntax podcast 2026-04-22.

## How to actually run it

1. **Detect changed paths and resolve tier.**

   ```bash
   BASE=$(git merge-base HEAD origin/master)
   CHANGED=$(git diff --name-only "$BASE"..HEAD)
   APP=$(echo "$CHANGED" | grep -oE '^apps/[^/]+' | head -n1 | cut -d/ -f2)
   ```

   Multi-app diffs: collect all `apps/<name>` prefixes, look each up,
   take the highest tier per ADR-026 §Composition.

2. **Run D1 (always).**

   ```bash
   mise run typecheck
   lefthook run ci-js --no-auto-install
   # ci-python only if the diff touched Python files
   echo "$CHANGED" | grep -qE '\.py$|pyproject\.toml$|uv\.lock$' && \
     lefthook run ci-python --no-auto-install
   ```

   `ci-js` covers D2 (architecture) and D3's `fallow-logging` leg. Report
   D2 and D3 separately so a future failure is greppable.

3. **D4 (conditional).** Skip unless the diff touches
   `packages/contracts`, `packages/db`, or `data/transformation/**`:

   ```bash
   if echo "$CHANGED" | grep -qE '^(packages/(contracts|db)|data/transformation)/'; then
     mise run contracts:check
   fi
   ```

4. **D5 (path-filtered).** Skip on README-only / `docs/**`-only diffs.
   When `verify-baseline` exists (post EAG-996), prefer it; until then, the
   `Docker Image Verify (Dagger)` job is the bridge — check the
   `.github/workflows/apps-pr.yml` run if CI already covered it, otherwise
   call Dagger locally per `.agents/skills/call-dagger/SKILL.md`.

5. **D6.** Re-run the pre-commit check explicitly against the diff:

   ```bash
   scripts/lefthook/check-prohibited-tools.sh
   ```

6. **Compose verdict.** Apply the tier matrix above. Print the output
   block.

## Reporting rules

Per `eagleeye-verification-gate` and AGENTS.md's "agents must run the
tools, not just acknowledge them" rule (Syntax podcast 2026-04-22):

- Every dimension line names the command and exit code.
- Skip rules are explicit: state the diff condition that caused the skip
  ("no `apps/**` files in diff" for D5 skip, "no contracts paths" for D4).
- Env-gated tests that skip due to missing vars are reported as **SKIP
  with the env var name** — never as PASS. See `eagleeye-verification-gate`
  Env-Gated Test Rule.
- Pre-existing failures **not introduced by this change** are reported as
  `⊝ ADVISORY pre-existing` with the file path. Diff to determine
  introduction: `git log -1 --format='%H' -- <file>` if the failing file
  wasn't in `CHANGED`, it's pre-existing.
- Flaky cold-cache D5 failures should be retried once before being
  reported as FAIL.

## Relationship to existing tooling

| Surface | Status | Note |
|---|---|---|
| `eagleeye-verification-gate` skill | Coexists with /verify | Lighter-weight runbook; pre-ADR-026. Cite when you need the matrix; /verify supersedes for tier-aware runs. |
| `.claude/settings.json` Stop hook | Not yet wired | ADR-026 §3 commits to one. /verify is what it will shell out to. |
| `.github/workflows/verification-scorecard.yml` | Not yet wired | ADR-026 §3 commits to one. /verify and the workflow MUST call the same tier resolver per ADR-026 §3. |
| `lefthook run pre-commit` | In use | D6 runs there today. /verify re-runs it post-stage. |
| `mise run fallow -- --summary` | Advisory | Per ADR-023; not a gate. /verify surfaces new findings attributable to the diff. |

## Failure modes to avoid

- **Saying "verify passed" without printing the block.** Always print the
  block, even if every dimension PASS'd — the user needs the evidence.
- **Reporting D5 PASS when the path filter caused a skip.** Print
  `⊘ SKIP — no apps/**/src/** in diff` instead. Skipping the dimension is
  not passing it.
- **Mixing "I ran commands earlier in the conversation" with verify
  output.** Re-run within the verify invocation so exit codes and timings
  are captured fresh. Stale evidence is no evidence.
- **Gating on D5 cold-cache flakes.** Retry once before reporting FAIL.
  Two consecutive cold-cache failures: report FAIL and link the runtime
  layer's known-flakiness note (ADR-026 §6).
- **Auto-bypass.** Never set `CLAUDE_BYPASS_VERIFY=1` yourself. It's the
  user's decision.

## Sources

- **[ADR-026](docs/decisions/architecture/ADR-026-agent-verification-loops/README.md)** — change-layer rubric, three loops, six dimensions.
- **[ADR-026 rubric.md](docs/decisions/architecture/ADR-026-agent-verification-loops/rubric.md)** — canonical D1–D6 definitions.
- **[ADR-026 tiers.yml](docs/decisions/architecture/ADR-026-agent-verification-loops/tiers.yml)** — app → tier registry. Substrate path: `docs/observability/tiers.yml` (post-implementation).
- **[ADR-028](docs/decisions/architecture/ADR-028-verification-baseline/README.md)** — names the seam between runtime + change layers; locates the shared substrate.
- **[eagleeye-verification-gate](.agents/skills/eagleeye-verification-gate/SKILL.md)** — runbook this skill builds on; coexists.
