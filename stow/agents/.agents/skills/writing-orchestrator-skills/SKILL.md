---
name: writing-orchestrator-skills
description: Companion to /skill-creator for skills that orchestrate multiple sub-skills, tools, or queries — the pattern that makes /deep-dive, /ic-memo, /quarterly-portfolio-review, and any future multi-block skill cheap to build. Encodes the dependency DAG, parallel fan-out via subagents, the rendered+evidence-pack return shape, context-budget rules, and which work stays in the caller vs gets dispatched. Use whenever a user is writing a skill that says "orchestrates", "composes", "fans out to", or names other skills it calls — and whenever the skill they're writing has more than one logical block that runs different queries or hits different sources. Use proactively when the skill being authored has subagents, parallelism, multiple data sources, or a long-running structure where context budget matters.
metadata:
  workspace: shared
  visibility: shared
---

# /writing-orchestrator-skills

Most skills are leaves — one task, one set of tools, one output. This skill is for the others: the orchestrator skills that compose multiple leaves into a single output. `/deep-dive` is the canonical example (eight blocks, four parallel subagents, structured evidence packs, ~30k caller-context budget across the whole run). The same shape applies to anything else that fans out to multiple data sources or sub-tasks.

`/skill-creator` covers what every skill needs: frontmatter, body, bundled resources, evals, description triggering. **This skill covers what orchestrator skills additionally need:** how to decompose, when to dispatch to subagents, how to design return shapes for composition, and how to keep the caller's context window from drowning under everything its subagents touched.

## When to invoke

- A user says "this skill orchestrates / composes / fans out to / chains" other skills.
- The skill being authored has > 2 logical blocks that hit different data sources or run different LLM calls.
- The skill needs to call subagents for parallelism or context isolation.
- The skill's outputs are expected to be composed by yet another skill downstream (e.g. `/deep-dive` → `/ic-memo`).
- The user is writing `/deep-dive`, `/ic-memo`, `/quarterly-portfolio-review`, or any analogous multi-input synthesiser.

Use after `/skill-creator` has been used to establish the skill's purpose, name, description, and basic body. This skill layers the orchestration concerns on top.

## The mental model — caller, leaves, evidence packs

An orchestrator skill has three actors:

1. **The caller** — the top-level skill that runs in the user's main context. Owns the DAG, sequences the fan-outs, composes the final output. Keeps a tight context budget.
2. **Leaves** — the sub-tasks dispatched to subagents (via the `Task` tool in Claude Code). Each leaf is self-contained: given inputs, produce rendered output + an evidence pack. The leaf never sees the user's full prompt or other leaves' outputs.
3. **Evidence packs** — the small structured JSON each leaf returns alongside its rendered output. Citations, key claims, flags, IDs. The caller uses evidence packs (not rendered outputs) to feed downstream synthesis steps.

## The dependency DAG — name it before you write code

Before implementing anything, **draw the DAG.** What are the leaves? Which depend on which? Where are the natural fan-out points? `/deep-dive`'s DAG:

```
ID resolution                   (caller, sequential)
      ↓
Block 2: Thesis fit             (caller, cheap) → sub_sector_slug
      ↓
─── parallel fan-out (4 subagents) ───
 Block 1, 3, 4, 5
─── join ───
      ↓
─── parallel fan-out (2: caller, subagent) ───
 Block 6 (caller, synthesises), Block 7 (subagent)
─── join ───
      ↓
Block 8: Questions              (caller, synthesises)
```

Three things to encode in the DAG:

- **Sequential prefix** — what must happen before the first fan-out (usually identifier resolution + a cheap classification step). These run in the caller.
- **Fan-out groups** — sets of leaves that have no dependencies on each other and can run in parallel.
- **Synthesis suffix** — the blocks that consume evidence packs from upstream and produce final output. These run in the caller because they need to see across the whole evidence pool.

## The three load-bearing rules

### Rule 1 — leaves get only what they need

The biggest mistake in orchestrator skills is leaking the caller's context into the leaves. Each leaf's input prompt should contain:

- **The leaf-specific inputs** (resolved IDs, sub-sector slug, the leaf's rubric, the required return shape).
- **Nothing else.** Not the user's full prompt. Not prior leaves' outputs. Not unrelated context.

This is what makes leaves cacheable across runs and keeps each leaf's own context tight. If a leaf needs information from another leaf, you've found a sequential dependency — restructure the DAG, don't paper over it by stuffing the upstream output into the downstream leaf's prompt.

### Rule 2 — leaves return rendered + evidence pack

Every leaf returns two things:

**`rendered`** — the HTML / markdown / structured output for this block. Ready to drop into the final artifact.

**`evidence`** — a small JSON object:

```json
{
  "block": "<id>",
  "self_score": 7,
  "rubric_check": [
    {"criterion": "...", "met": true|false|"partial", "reason": "..."}
  ],
  "citations": [
    {"marker": "[H]", "source": "...", "url": "...", "row_id": "..."}
  ],
  "key_claims": ["..."],
  "flags": ["..."],
  "ids": {"...": "..."}
}
```

**Why two outputs:** the caller stitches `rendered` blocks into the final artifact. Downstream synthesis blocks consume the `evidence` packs, not the rendered prose. This is the single trick that makes composition cheap — Block 8 of `/deep-dive` synthesises across all upstream blocks but only sees ~5 KB of structured evidence per block, not the full rendered output that may run to ~30 KB of HTML.

### Rule 3 — synthesis blocks stay in the caller

The blocks that consume upstream evidence packs (the "join" steps in the DAG) run in the caller, not in subagents. Two reasons:

1. **They need to see across the whole evidence pool.** A subagent dedicated to one synthesis step would need every upstream evidence pack as input — defeating Rule 1.
2. **Their inputs are already small.** Evidence packs are structured JSON, not prose. The caller can hold many of them without context bloat.

In `/deep-dive`: Block 6 (Risk + tripwires) and Block 8 (Questions for the call) are both synthesis blocks; both run in the caller. Block 7 (Catalysts) is independent — runs in a subagent.

## Context budget — count it before you write it

A well-orchestrated skill should keep the caller under ~30k tokens across the whole run, regardless of how much data the warehouse or web returned to subagents. Back-of-envelope:

| Element                              | Approx tokens |
|--------------------------------------|---------------|
| User's original prompt               | ~500          |
| ID resolution result (JSON)          | ~200          |
| Block 2 result (caller-run)          | ~500          |
| 4 evidence packs from fan-out 1      | ~5,000 each = ~20k |
| 2 evidence packs from fan-out 2      | ~2,500 each = ~5k  |
| Final synthesis (caller)             | ~3k           |
| **Total**                            | **~29k**      |

The rendered HTML blocks (~30k each in the worst case) never enter the caller's context — they stay in the subagents that produced them and only get stitched together at output time. **This is the property that makes the orchestrator pattern feasible.**

## Mechanically in Claude Code

The fan-outs are one message with multiple `Task` calls:

```
[Message 1] Dispatch fan-out 1: 4 Task calls in parallel
            → all 4 subagents start at the same time
            → caller waits for all 4 to return

[Message 2] Dispatch fan-out 2: 2 Task calls in parallel
            (or 1 Task + 1 inline if one synthesis stays in caller)

[Message 3] Inline synthesis (Block 8)
```

Three message turns total. ~4× wall-clock speedup over a sequential implementation. Use progress messages between fan-outs ("Resolved IDs · classifying · fanning out 4 deep queries…") so the user sees the work happening rather than a silent wait.

## The orchestrator skill SKILL.md — what to include

The orchestrator's `SKILL.md` body should explicitly contain:

1. **The DAG diagram.** ASCII in a `<pre>` block. Reader should be able to see the whole flow at a glance.
2. **The leaf contract.** What each subagent gets as input, what shape it returns. Concrete enough that someone can implement a new leaf without re-deriving the rules.
3. **The rubric per leaf** (in a `references/rubrics.md` file). Each leaf self-scores; the caller surfaces the scores in the rendered output for the reader.
4. **The evidence-pack schema.** What's in `citations[]`, `key_claims[]`, `flags[]`. Stable across leaves so the synthesis blocks can rely on the shape.
5. **The context budget.** A back-of-envelope token count showing the orchestrator stays inside a reasonable budget.

`/deep-dive`'s SKILL.md is the canonical reference — see `eb/ic/deep-dive/SKILL.md` and its `references/dag.md`.

## Composition metadata — two fields per skill

The orchestrator graph is navigable without a registry or build step: every skill carries its place in the graph in its own frontmatter. Two fields, both under `metadata:`:

```yaml
metadata:
  shape: leaf              # leaf | orchestrator
  used-by-skills:          # informational; drift-tolerant
    - deep-dive
    - ic-memo
```

**`shape`** — `leaf` if invoked as a sub-task in someone else's DAG; `orchestrator` if it composes leaves. Skills without `shape:` are conventional workflow skills outside the composition graph (`/standup`, `/toggle-mode`, `/handoff`).

**`used-by-skills:`** — the orchestrators known to compose this leaf. Drift-tolerant — when an orchestrator gains or drops a leaf, the leaf's list may go stale. That's OK. The canonical source remains each orchestrator's own SKILL.md body. This field is for **discovery from the leaf side**: when you're about to change a leaf, you want to know who will feel it.

Orchestrators don't need a mirror `composes:` field — their body already names the leaves they call. The leaf-side pointer is the one worth pinning because it's harder to derive otherwise.

Inputs, outputs, evidence-pack shape, rubric — all stay as prose in the SKILL.md body, not as structured frontmatter fields. The composition graph deserves machine-readable metadata; the leaf's internal contract does not. Promote a field to frontmatter only when something other than a human reader needs to consume it.

**Worked example:** `/portfolio-catalysts` is the first leaf tagged with this metadata. See its frontmatter.

## When the orchestrator pattern is wrong

Not every skill should be an orchestrator. **Use the leaf pattern (one `SKILL.md`, no subagents) when:**

- The skill has one logical task, even if it touches multiple data sources sequentially.
- The total work fits in the caller's context comfortably.
- The output is a single answer, not a composed artifact.

`earlybird-read-affinity-crm` is a leaf. `/daily` is a borderline case — eight blocks, but each is small and sequential, so it runs in the caller. `/deep-dive` is a true orchestrator — heavy parallel SQL + synthesis.

The wrong move is to add subagents to a skill that doesn't need them: every fan-out adds latency, complexity, and a layer where the leaf's context can drift from the caller's intent. **Reach for the orchestrator pattern only when the context budget forces it, or when wall-clock matters and the leaves are genuinely independent.**

## Authoring checklist

When writing or reviewing an orchestrator skill, walk through this:

- [ ] DAG drawn and included in the SKILL.md as ASCII.
- [ ] Sequential prefix identified — what must run before the first fan-out?
- [ ] Fan-out groups identified — which leaves have no inter-dependencies?
- [ ] Synthesis suffix identified — which steps consume evidence and produce final output?
- [ ] Each leaf has a clearly defined input contract (IDs, rubric, return shape).
- [ ] Each leaf returns rendered + evidence (not just rendered).
- [ ] Evidence-pack schema documented and consistent across leaves.
- [ ] Synthesis blocks consume evidence packs, not rendered outputs.
- [ ] Synthesis blocks run in the caller.
- [ ] Context-budget envelope sketched (~30k caller is the target).
- [ ] Parallel fan-out implemented as multi-`Task`-call messages, not sequential.
- [ ] Progress messages between fan-outs so the user sees activity.
- [ ] Per-leaf rubrics stored in `references/rubrics.md`.

## Files in this skill

- `SKILL.md` — this file.
- `references/leaf-contract.md` — full schema for the leaf input prompt and the rendered + evidence return shape.
- `references/dag-patterns.md` — common DAG shapes (fan-out + join, pipeline, diamond) with worked examples.

## Related skills

- `shared/skill-creator/` — covers what every skill needs (frontmatter, body, evals, triggering). Use that first.
- `eb/ic/deep-dive/` — canonical worked example. Read its `SKILL.md` and `references/dag.md` for the concrete instantiation of every rule in this skill.
- `eb/ic/ic-memo/` (future) — second orchestrator skill, will validate whether this meta-skill paid off.
