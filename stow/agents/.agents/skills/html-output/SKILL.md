---
name: html-output
description: Default to HTML over Markdown when Claude needs to communicate rich, scannable, or visual output back to the user. Provides the Earlybird brand base — colors, Untitled Sans + Condensed Sans No.10 typography, light/dark mode — as a copy-paste stylesheet plus a fully-loaded scrollable-document template with keyboard nav and section sidebar. Trigger on "make this an HTML page", "render as HTML", "HTML artifact", "make me an HTML file", "drop this in HTML", "highly visual output", "make it easier to reason about", "ad-hoc website for this", "quick presentation", plus specific use cases: side-by-side option comparisons, PR/code explainers with diffs and annotations, design exploration grids (mockups, pricing tables, layout variants), implementation plans with diagrams and code snippets, weekly status or research reports, throwaway editors (drag-and-drop card sorters, feature-flag editors, prompt-tuning UIs with copy-as-export), decision briefs, post-mortems, alignment memos, technical explainers with SVG flowcharts. Use proactively whenever the user asks for output that benefits from color, hierarchy, tables, diagrams, side-by-side comparisons, or interactive controls — even if they don't explicitly say HTML. Companion skills handle the deeper craft: frontend-design for bold custom aesthetic direction outside Earlybird brand, web-artifacts-builder for React/Tailwind/shadcn artifacts with state, html-presentation for slide decks, web-clone for cloning a live URL.
---

# HTML Output

Default to HTML over Markdown for output the user actually needs to read.

Markdown is fine for terse logs and inline answers. But once an artifact is longer than ~100 lines, or needs color, diagrams, tables, side-by-side comparisons, or any kind of visual hierarchy, HTML wins. It's denser, scannier, more shareable, and the user is dramatically more likely to actually open it. (Long-form take: https://thariqs.github.io/html-effectiveness/)

This skill provides **the Earlybird brand base** — colors, typography, light/dark mode, keyboard layer — so HTML output looks coherent without having to think about styling. The other HTML skills handle component design and visual hierarchy; this one is the brand shell on top.

## Read this before you start writing

**`~/.agents/skills/html-presentation/references/brand-quick.md` is the canonical brand spec.** Read it once before producing any Earlybird-shelled HTML — especially the typography section. The two non-obvious rules that produce most off-brand output:

1. **Body font is Untitled Sans. Headlines are Condensed Sans No.10.** Inter and Oswald are *fallbacks only* — never defaults. The stylesheets in this skill put the brand fonts first and load them via `local()`; the Google Fonts imports are safety nets, not the primary stack.
2. **Earlybird = refined minimalism, not maximalism.** No backdrop typography, no dotted-grid backgrounds, no noise overlays, no gradient meshes. When reaching for `frontend-design` techniques inside an Earlybird-shelled doc, "pop" means precision and restraint executed sharply — bigger Condensed Sans No.10 headlines, tighter rhythm, sharper red accents. Reserve `frontend-design`'s maximalism vocabulary for pages that deliberately break the brand (creative landing pages, distinctive marketing pieces).

If the artifact is for an external audience, also check `brand-quick.md`'s logo + gradient + confidentiality rules.

## Conventions (apply to every artifact this skill produces)

These four conventions are load-bearing — they're what makes Earlybird HTML *feel* like Earlybird HTML at a glance, and they're what makes the artifact actually usable without ceremony.

### 1. Local fonts only — never embed OTFs

The brand fonts (Untitled Sans body + Condensed Sans No10 display) load via `@font-face { src: local(...) }`. Earlybirders have them installed; everyone else gets the Google-Fonts-loaded Inter / Oswald fallback (a few KB each, cached across artifacts).

**Don't** ship `url('assets/fonts/UntitledSans-Regular.otf')` or base64-encoded font data in this skill's output. Each brand OTF is 100–200 KiB; embedding 3–4 weights adds ~600 KiB per artifact, which defeats the "shareable on the spot" intent. The `html-presentation` skill is the deliberate exception (decks need to work fully offline as a single attachment) — don't take its pattern here.

### 2. Earlybird logo top-left, always. EagleEye logo too when the artifact concerns EagleEye work.

Fixed top-left position is the visual anchor that says "Earlybird artifact" before the reader has parsed any prose. For EagleEye-specific work (anything in `~/code/eagleeye/...` or about EagleEye product / data / pipelines), pair the Earlybird logo with the EagleEye logo separated by a thin vertical divider. For pure Earlybird memos (firm operations, IR, fund-level decisions, partner briefs not tied to EagleEye), the EagleEye logo can be omitted — but Earlybird stays.

Both logos have light- and dark-mode variants — swap based on the theme class on `<html>`. The `doc.html` template ships with the markup wired up and the asset files in `assets/template/assets/` — just remove the EagleEye block for non-EagleEye artifacts.

### 3. Left sidebar by default (for M/L artifacts)

Anything longer than a single-section page (briefs, memos, alignment docs, walkthroughs, post-mortems, status reports) uses the left sidebar pattern from `doc.html`: collapsible (`b` keybind), auto-built from `.section-title` elements, scroll-sync highlight. Readers jump between sections without scrolling through prose.

Skip the sidebar when:
- It's a single-section artifact (a one-page pitch, a press-release-style page) — sidebar redundant
- The page is canvas-dominated and a horizontally-scrolling SVG already eats the horizontal real estate
- It's a side-by-side comparison grid that fits in one viewport with no internal navigation

### 4. Brand font name is `Condensed Sans No10` — no period

The registered font family is `Condensed Sans No10` (no period after "No"). Older artifacts had `Condensed Sans No.10`, which is a different family name that falls through to the Oswald fallback even on systems with the brand OTF installed. All stylesheets in this skill use the correct name.

## When to reach for HTML (and this skill)

The skill's trigger surface is deliberately broad. Concrete cases where HTML wins:

**Specs, planning, exploration.** "Generate 6 onboarding approaches side-by-side, labelled with tradeoffs." "Implementation plan with mockups, data flow, key code snippets I can review." "Three approaches to this problem with tradeoffs."

**Code review & PR explainers.** "Render the diff with inline annotations, severity-colored findings." "HTML explainer for this PR — diagram the streaming logic." "Help me understand how this rate limiter works — diagram + annotated snippets + gotchas."

**Design & prototypes.** "Prototype this checkout-button animation with sliders to tune parameters." "Mockup three layout options as HTML I can compare." "Build a design system reference from this codebase."

**Reports, research, learning.** "Weekly status from Slack + Linear + git, rendered as HTML." "Incident post-mortem: timeline, contributing factors, fixes." "Decision brief: situation, options, recommendation, owners, timeline." "Alignment memo capturing meeting outcomes + the v0.5 spec."

**Custom editing interfaces (throwaway editors).** "Drag-and-drop Kanban for these 30 tickets with copy-as-JSON export." "Feature flag editor — group flags, show dependencies, copy-as-diff." "Side-by-side prompt tuner with live preview + token counter + copy button."

**Anything visual.** Tables with structure, SVG diagrams, code with syntax callouts, color-coded categories, multi-pane layouts, sortable/filterable lists.

If the user says "quick HTML page so I can share it" → reach for this skill.

## When a companion skill is the better fit

This skill provides the brand shell. The other HTML skills handle deeper craft:

- **Slide deck** with one-idea-per-slide structure → `html-presentation`
- **Interactive React app or claude.ai artifact** with state, routing, shadcn components → `web-artifacts-builder`
- **Bold custom aesthetic direction** outside Earlybird brand (creative landing page, distinctive marketing piece) → `frontend-design`
- **Cloning an existing live URL** → `web-clone`
- **Reviewing existing UI** for accessibility / web-interface guidelines → `web-design-guidelines`

### Composing with `frontend-design` inside Earlybird-shelled output

`frontend-design`'s creative axis is "pick a BOLD aesthetic direction." Earlybird's direction is **refined minimalism** — pre-chosen. Inside an Earlybird-shelled artifact, borrow `frontend-design`'s **execution craft** (sharp typography, intentional motion, asymmetric layouts, hover micro-interactions) but **not** its maximalism vocabulary. Concretely:

| Borrow from `frontend-design` | Don't borrow |
|---|---|
| Staggered fade-in on initial load (`IntersectionObserver`) | Backdrop "watermark" typography |
| Hover lift + red glow on cards | Dotted-grid or gradient-mesh backgrounds |
| Bigger Condensed Sans No.10 headlines, tighter line-height | Noise overlays / `feTurbulence` filters |
| Asymmetric kicker + accent rule | Layered transparencies, custom cursors |
| Sharp red accents on borders, dots, arrows | Multi-hue gradient backgrounds |

If the artifact is meant to deliberately break the brand (creative landing page, distinctive marketing piece), drop the Earlybird shell entirely and let `frontend-design` lead.

### Composing with `web-artifacts-builder`

Use this skill's `earlybird-base.css` inside a `web-artifacts-builder` React project to keep typography + colors brand-consistent while gaining state, routing, and shadcn primitives.

## What this skill gives you

**1. `assets/template/earlybird-base.css`** — the brand shell as a standalone stylesheet (~180 lines). Drop into any HTML artifact via `<style>` tag and get Earlybird typography (Untitled Sans + Condensed Sans No.10 via `local()`, with Inter/Oswald fallback nets), colors, light/dark, base callouts. **This is the primary artifact.** Use it for XS/M artifacts where you don't need a full doc scaffold. Note: it's a shell, not the full brand spec — for logo rules, gradient usage, and confidentiality markers, read the canonical reference at #4.

**2. `assets/template/doc.html`** — a fully-loaded scrollable document template. Sidebar, keyboard layer (`j`/`k`/`gg`/`G`/`b`/`d`/`?`), light/dark toggle, help overlay, print-friendly media query. Use when the artifact is long enough to need section navigation (briefs, memos, alignment docs, post-mortems).

**3. `references/layouts.md`** — a patterns library, not a structure. Copy-paste HTML for: gap-card with options + diff, before/after side-by-side (paragraph + structural variants), timeline, owners grid, status callouts, parked cards, per-group breakdown, transcript quotes, decision banner, handoff callout. Patterns are composable building blocks; pick what the content needs.

**4. Earlybird brand reference (canonical)** — `~/.agents/skills/html-presentation/references/brand-quick.md` is the source of truth for typography, colors, logo, gradient, and confidentiality rules. The "Read this before you start writing" section above flags the two rules most likely to produce off-brand output if missed; read the full reference for everything else.

## Three sizes of artifact — pick the right starting point

### Size XS (~50-200 lines) — one-page artifact, no sidebar

The 80% case. A pricing-table comparison grid, a quick Kanban editor, a 4-mockup side-by-side, a code-explainer with one diagram + 3 snippets.

1. Start with a minimal HTML skeleton.
2. Drop `earlybird-base.css` into a `<style>` block (or `@import` it if hosted).
3. Write your body — pick patterns from `references/layouts.md` if useful, but don't feel obliged.
4. Save and open.

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Your artifact</title>
<style>
  /* paste contents of assets/template/earlybird-base.css here */
</style>
</head>
<body>

<!-- Logos top-left (convention #2). Drop logo SVG/PNG files in ./assets/.
     Keep both for EagleEye work; remove the EagleEye block otherwise. -->
<div class="logo">
  <img class="ee-light-mode" src="./assets/Earlybird_Logo_RGB_Red.svg" alt="Earlybird" />
  <img class="ee-dark-mode"  src="./assets/Earlybird_Logo_RGB_White.svg" alt="Earlybird" />
  <span class="sep"></span>
  <img class="ee-light-mode" src="./assets/eagleeye-logo.png" alt="EagleEye" />
  <img class="ee-dark-mode"  src="./assets/eagleeye-logo-dark.png" alt="EagleEye" />
</div>

<div class="container">
  <header>
    <div class="classification">Strictly Confidential · Internal</div>
    <h1>Your title</h1>
    <div class="subtitle">Date · audience</div>
  </header>

  <!-- Your content. Use h2.section-title for headers, .card for boxed content,
       .headline for callouts. See layouts.md for richer patterns. -->

</div>
</body>
</html>
```

### Size M (~200-600 lines) — multi-section doc with sidebar

A research memo, weekly status report, technical explainer. Starts to need navigation.

Copy `assets/template/doc.html`, replace the placeholder header + example section with real content. Sidebar, keyboard layer, light/dark already wired.

### Size L (~600+ lines) — fully-loaded decision brief or post-mortem

Multiple sections, options grids, before/after diffs, owners, timeline, parked items. Same as M, but pull more patterns from `references/layouts.md`.

The known-good example is `~/code/eagleeye/.claude/worktrees/compliance/briefs/2026-05-13-claude-dpia-alignment/discussion.html` — uses most of the library.

## Keyboard shortcuts (Size M/L only)

The `doc.html` template ships with these wired:

| Key                | Effect                                  |
|--------------------|-----------------------------------------|
| `j` / `k`          | Next / previous section                 |
| `gg` / `G`         | Top / bottom of page                    |
| `b`                | Toggle section sidebar                  |
| `d`                | Toggle dark / light theme               |
| `?`                | Show keyboard-shortcut help overlay     |
| `Esc`              | Close overlay or sidebar                |

Sidebar auto-builds from each `.section-title` element. Theme + sidebar state persist in `localStorage`. Vim users: `j` / `k` / `gg` / `G` / `?` work as expected.

XS artifacts skip the keyboard layer — they're short enough to scroll natively.

## Writing principles

- **Default to HTML, not markdown** for anything the user actually needs to read. The article-length take is that markdown's editing advantage matters less now (you mostly prompt Claude to edit anyway), while HTML's expressiveness, density, and shareability all compound.
- **Headlines describe the decision, not the topic.** "Drop Art. 14(5)(b) — recipient framing + outbound notice" beats "Transparency obligations".
- **Color discipline.** Red = brand + active blockers. Orange = major / in-flight. Green = resolved / decided. Yellow = open / pending. Gray = cleanup / parked. The brand-base CSS exposes these as variables.
- **Use bold for emphasis, not all caps.** Caps are for section titles (Oswald).
- **End interactive artifacts with an export.** Throwaway editors should have a "copy as JSON" / "copy as prompt" / "copy as markdown" button so the work in the UI can be pasted back into Claude Code or another tool.
- **SVG over ASCII for diagrams.** If the model wants to show a flowchart, a token-bucket, or any spatial relationship, write SVG. Don't approximate with markdown box-drawing characters.
- **Default to light mode** for memos that will be printed / PDF'd / shared widely. Default to dark for read-on-screen ad-hoc artifacts. The toggle (where present) gives the reader the final say.
- **Don't over-engineer.** Three patterns from layouts.md may be all you need. Skip sections that don't apply. Patterns are a library, not a checklist.

## Confidentiality marker

Internal / strategic docs need "strictly confidential" top-right:

```html
<div class="classification">Strictly Confidential · Internal</div>
```

## Sharing the output

- **Email attachment.** Recipient downloads → opens in browser. Works for technical-internal audiences. Gmail's preview strips JS, so deep interactivity is download-only.
- **Print to PDF.** Loses interactivity but renders identically. Best for non-technical recipients.
- **Cloud Run + `ee-webapp-auth` pattern** (in EagleEye repo). Durable answer for an ongoing artefact surface with earlybird.com-only access.
- **Google Drive upload.** Drive preview strips JS; recipient must "Open in browser". Friction.
- **S3 / GCS bucket with a signed URL.** Simplest for one-off sharing if the artifact is non-sensitive.

## Two-way interaction patterns

When the artifact needs to round-trip back to Claude Code:

- **Copy buttons.** End every editable artifact with a "Copy as JSON" / "Copy as markdown" / "Copy as prompt" button that exports the final state. Reading back into Claude is then a paste.
- **Form fields with `localStorage`.** Persists the user's edits across reloads.
- **`history.replaceState` for URL state.** Share-a-link that opens with the user's edits intact.

## References

- `assets/template/earlybird-base.css` — brand-only stylesheet, the primary artifact
- `assets/template/doc.html` — full scrollable document scaffold for M/L
- `references/layouts.md` — patterns library, composable building blocks
- `~/.agents/skills/html-presentation/references/brand-quick.md` — canonical Earlybird brand reference (full spec)

## Known good example

`~/code/eagleeye/.claude/worktrees/compliance/briefs/2026-05-13-claude-dpia-alignment/discussion.html` — DPIA v0.5 alignment doc, Size L, uses most of the library. Best reference for what a fully-loaded doc looks like.
