---
name: shape
description: Shape work into a walkable HTML pair — pitch.html (partner-readable argument) + details.html (scope, capabilities, inline-SVG lifecycle canvas, open decisions). Defaults to tracer-bullet vertical slices — smallest end-to-end path first, durable architecture second. Use this skill whenever the user wants to shape work, write a PRD, scope a feature, design a capability, or says "shape this", "let's PRD this", "spec this out", "design this", "frame this for the team". Also trigger when the user asks for a one-page memo arguing for a product investment, when they've described a feature and want a structured artifact for partner review, or when shaping output that downstream agents (/linear) will turn into issues. After shaping, use /linear to commit to Linear.
---

# Shape

Produce a walkable, visual HTML pair that argues for a piece of work and lays out its slices, capabilities, lifecycle, and open decisions. Two files (plus a sidecar JSON for the canvas) — designed for top-down skim, partner-shareable, and structurally rich enough that downstream agents can pull from them.

## Why HTML, not markdown

Markdown files force the reader to imagine the visual: 6 capabilities = 6 paragraphs to grep through; an event storm = an ASCII diagram. The shape stops being a *shape* and becomes a wall of prose. HTML is the right medium for shape because:

- **It's the same effort to produce, with massively more information per glance.** Colored cards, swimlanes, and a real canvas land differently than `## Capabilities` followed by bullets.
- **It rewards skim.** A partner who has 90 seconds for the pitch reads `pitch.html`; the team reads `details.html` end-to-end. Two artifacts with different audiences, both walkable.
- **It compresses the lifecycle.** A user-story-map + event-storm SVG carries the work of three markdown sections (scenarios, state diagrams, sequencing) in one scannable image.
- **Agents read HTML.** `/linear` and other downstream agents can parse the same structure humans see — capability cards become issues, slice swimlanes become projects, event-storm events become acceptance criteria.

## When to use

The user has a thing they want to do — a feature, a workflow, a system change — and wants to argue for it, scope it, and hand it off cleanly. Use `/shape` *before* writing code, *before* cutting issues, *after* the rough idea is in the head but before partner / team review.

**Don't use `/shape` for:**
- Implementation plans for already-shaped work (use `docs/plans/<date>-<slug>-design.md`)
- Architecture decisions with explicit accept/reject context (use ADRs in `docs/decisions/architecture/`)
- Sprint tracking (use `.planning/`)

## Process

### 1. Prime (if not already primed)

If `/prime` hasn't been run in this session, load the project context (vision, strategy, roadmap, domain architecture) before doing anything else. The pitch is hollow without it.

### 2. Get the problem

Ask the user for a description of what they want to solve. Keep it conversational — they'll refine through the artifact, not through a Q&A flow. One paragraph is enough to start.

### 3. Determine output location

Check in order:

1. **User's personal agent config** — look for a `planning` or `notes` setting in `~/.agents/AGENTS.md` or `~/.claude/CLAUDE.md` that specifies a preferred folder.
2. **Project AGENTS.md / CLAUDE.md** — many repos document where design docs live (e.g., `docs/plans/YYYY-MM-DD-<slug>/`). Honor that convention over this skill's default.
3. **Ask the user** if neither config points clearly somewhere.
4. **Fall back to repo** — create `docs/plans/<YYYY-MM-DD>-<slug>/` in the current repo.

The output folder gets:

```text
{output-location}/<YYYY-MM-DD>-<slug>/
  pitch.html      ← partner-readable one-page argument
  details.html    ← team-readable scope · capabilities · canvas · open decisions
  shape.json      ← canvas source-of-truth (USM + event storm content) — /linear reads this
```

### 4. Explore the codebase

Discover what already exists:

- Which packages / modules touch this problem space
- What interfaces could be extended vs. built from scratch
- Whether this has been tried before (`git log`, related docs)

#### Primitive-existence check (non-skippable)

Any time the shape names a port, helper, adapter, type, mapper, schema, renderer, or any architectural primitive, **grep for it before writing the capability cards**. The check is cheap — 30 seconds of `rg` plus, if the surface is unclear, a fan-out of read-only agents. Skipping it is how shapes invent abstractions the codebase already provides.

A useful default sweep, adapted to whatever the shape names:

```bash
rg -l "EnrichmentPort" packages/ apps/*/src/      # the exact symbol
rg -l "enrichment\\.port|enrichment-port" packages/ apps/*/src/   # path-style variants
rg -l "normaliseDomain|normalizeDomain" packages/ apps/*/src/     # likely-named helpers
```

If a primitive turns up:

- The shape pivots from **"build X"** to **"compose X"** for that primitive. The capability card's Layer/Modality line should say `(reuse from @scope/pkg)` so the reader (and `/linear`) sees at a glance which work is wiring vs. new code.
- The path the shape walks usually collapses by a slice or two — what looked like "PR-1: build the port, PR-2: wire it" becomes "PR-1: compose + wire," because the port already exists.
- If the primitive is *almost* what's needed but not quite, the shape names the gap explicitly (a single new method on the existing port, or a thin wrapper) instead of duplicating the whole abstraction.

**Worked example (EAG-1016 Slice 2, classify-company enrichment).** The handoff said "add an `EnrichmentPort` to `packages/sourcing/classify-company`." The shape-time grep found `EnrichmentPort`, `EnrichmentSignals`, `EnrichmentLookup`, `normaliseDomain()`, a `CompositeEnrichmentAdapter`, three live BigQuery adapters, and a matching `SourceBadges` renderer — all in `@eagleeye/eval` and `apps/investment-thesis/src/db/`. Slice 2 collapsed from "build the abstraction + wire it" to "compose what's there + drop Crunchbase per the licence wind-down + add the source-coverage UI row." A duplicate port in classify-company would have been a maintenance hazard nobody asked for, with no boundary justification to defend it.

### 5. Grill — minimal

Only ask about gaps the codebase can't answer. Focus on:

- Ambiguous intent (multiple valid interpretations)
- Priority conflicts (this vs. competing work)
- Scope boundaries (what's explicitly out)

### 6. Default to a tracer-bullet shape

Shape the smallest end-to-end vertical slice that proves the whole pipeline works *before* designing the durable architecture. The slice itself follows the vertical-slice rules in `/linear` — what's mandatory here at shape time is the **bias**:

- Tracer first, durable architecture second — even when the user asks for the proper version.
- The tracer surfaces which signals actually move the metric, which informs the durable schema. Skipping it spends weeks designing the wrong abstraction.
- In `shape.json.canvas.story_map.slices`, **Slice 1 must be a complete vertical path** through the backbone — sparse but end-to-end. Slice 2 / 3 fill in cells row by row.

Skip the tracer only when (a) the pipeline shape is already proven by earlier work or production code, or (b) the work is operational / migration with a known correct end state.

### 7. Write the three files

Write **`shape.json` first** — the canvas is the spine of the lifecycle and forces clarity about who does what, in which slice. Then write `details.html` (which embeds the canvas SVG), then `pitch.html` (which the canvas + details make easy to argue for).

Use the bundled examples as a starting point:

- [`references/example_pitch.html`](references/example_pitch.html) — full-page pitch with brand styling
- [`references/example_details.html`](references/example_details.html) — full-page details with inline-SVG canvas
- [`references/example_shape.json`](references/example_shape.json) — worked example
- [`references/canvas_data.md`](references/canvas_data.md) — `shape.json` schema + Brandolini palette

**Generate the canvas SVG** via the bundled builder:

```bash
python scripts/build_canvas_svg.py shape.json --out /tmp/canvas.svg
# then paste /tmp/canvas.svg content between the <!-- canvas:start --> / <!-- canvas:end --> markers
# in details.html
```

The builder is deterministic — fixed sticky sizes, no autosize ambiguity. That's why we use inline SVG rather than `.excalidraw`: it renders correctly on first read, no app open / re-layout step. See `feedback_shape_inline_svg_canvas` for context on this trade-off.

### 7b. Other diagrams in details.html — use Mermaid

The lifecycle canvas (USM + event storm) is the only diagram `/shape` produces *by default*. If the shaped feature has other diagrams that genuinely help the reader — a sequence diagram for a critical interaction, a state machine for a workflow, a C4 architecture sketch, an ERD for a data model — embed them in `details.html` using **Mermaid**, not hand-authored SVG.

Drop the Earlybird-themed Mermaid initialization from `~/.agents/skills/html-output/references/mermaid-earlybird-theme.md` into the page once, then add `<pre class="mermaid">…</pre>` blocks wherever the diagram belongs. Light/dark themes swap with the existing `d` keybind. Don't reinvent SVG layout for diagram types Mermaid already does well — the deterministic-SVG path is reserved for shapes Mermaid can't express well (slice swimlanes, USM backbones, Brandolini sticky-note layouts).

### 8. Decision gate

After writing, tell the user where the files are. Suggest:

> Open `details.html`. The open-decisions section has empty answer slots — review and fill them. When you're ready, run `/linear` to create initiative / projects / issues.

Do NOT create Linear issues from this skill — that's `/linear`'s job. Implementation details, risks, and feature files land during `/linear` or in the conversation that follows shaping, not as upfront artifacts.

## What goes in each file

### pitch.html

One page. Read in 60–90 seconds. Audience = partner / decision-maker / anyone who needs to know what we're investing in and why. Structure:

1. **Eyebrow + Title + Subtitle** — what this is and who it's for
2. **Headline blockquote** — the one-sentence argument (the thing that, if it doesn't excite, kills the project)
3. **Why now** — the strategic moment + the gap we're filling
4. **The pitch** — for whom, what we ship, what changes
5. **Fictional quote** — what a user / partner / team-member would plausibly say after it ships. Realistic, not jargon.
6. **How it works** — 3–4 cards, no jargon, one verb each
7. **CTA** — "Next read: → details.html"

If pitch.html doesn't make you want to ship, the shape isn't worth building. Press-release-style. See `references/example_pitch.html`.

### details.html

Audience = the team that'll build it, plus the partner who wants to check the scope. Structure:

1. **Header** with breadcrumb back to pitch + Table-of-contents pills
2. **Problem** — 1–2 paragraphs, user perspective
3. **Scope** — two cards side-by-side: scope-in, scope-out. Maximum 5 bullets per side.
4. **Success metric** — a single, measurable outcome with the "why this number" sentence
5. **Capabilities** — verb-noun cards, one per capability. Each carries `domain` (bounded context) and `modalities` (cli / web / mcp / cron / etc).
6. **Lifecycle canvas** — inline SVG between `<!-- canvas:start -->` / `<!-- canvas:end -->`. Story map (slices) on top, event storm below.
7. **Open decisions** — accordion of decisions awaiting input. Each has a severity (`ship-gate` / `owner-needed` / `spike`), a body explaining the trade-off, and an empty answer slot.
8. **Next step** — "When the answers are in, run `/linear`."

The SVG carries the work of (a) scenario lists, (b) state diagrams, (c) sequencing diagrams, all in one scannable image. Don't duplicate it as text.

### shape.json

Source of truth for the canvas. See [`references/canvas_data.md`](references/canvas_data.md) for the schema. The `/linear` skill reads this directly when carving issues — slice = project, event-storm event = acceptance criterion, capability card = issue.

## Iterating with the user

After the files are written, walk the user through them sequentially:

1. **pitch.html** first — does the argument land?
2. **details.html** scope card — anything in-scope that should be out, or vice versa?
3. **details.html** capabilities — naming, domain placement, missing verbs?
4. **details.html** canvas — does the slice ordering match the strategy? Do the events cover the failure paths?
5. **details.html** open decisions — fill what you can answer; flag the rest.

**Edit in place as answers come in.** Don't accumulate a queue of "next iteration" notes — the whole point of two HTML files is that ripple cost stays manageable. A capability rename in capabilities propagates by find-replace; a slice re-cut means regenerating the canvas via `build_canvas_svg.py`.

## Anti-patterns

- **Writing an "implementation plan" file**. That's a separate doc (`docs/plans/<date>-<slug>-design.md`). `/shape` is what you decide *to build*, not how you'll build it.
- **Adding `.excalidraw` files**. Inline SVG is the default — render-correct on first read, no app to open, no overlap fixes. Generate `.excalidraw` only on explicit ask.
- **Filling answer slots speculatively**. Leave them empty unless the user has answered them. Their emptiness is a forcing function.
- **Writing scenarios as Gherkin**. The event storm replaces them — events are the acceptance criteria, the canvas shows their ordering and dependencies. `/linear` derives Gherkin from the storm when issues are cut.
- **Letting the canvas drift from `shape.json`**. The SVG is generated. If you hand-edit the SVG, regenerate it from updated JSON instead.
- **Inventing a primitive the codebase already provides.** Naming a port / helper / adapter / type without first `rg`-ing for it across `packages/` and `apps/*/src/`. The 30-second pre-shape check (see step 4 · Primitive-existence check) prevents a duplicate abstraction nobody asked for.

## Next step: /linear

When the open-decision answers are in, point the user to `/linear`. That skill handles:

- Strategic placement (initiative selection)
- Change assessment (new / changing / removing)
- Project grouping by slice (from `shape.json.canvas.story_map.slices`)
- Issue breakdown with AFK/HITL classification and dependency ordering (using the event storm)
- Implementation details and ubiquitous-language merging — derived from the shape + the conversation context

If the project genuinely needs a separate design doc (migration spec, data model with a known correct end state, ADR-adjacent rationale), write that as a standalone file outside the shape — e.g. `docs/plans/<date>-<slug>-design.md`.
