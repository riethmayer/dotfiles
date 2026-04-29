---
name: html-presentation
description: Build self-contained, single-file HTML presentations (one `.html` with all CSS, images, fonts, and logos inlined as base64) in the Earlybird brand. Use whenever the user wants an HTML deck, slides that work offline, a "portable" or "standalone" presentation, a browser-based talk, an artefact that can be emailed or uploaded without a supporting folder, or a swap for PowerPoint/Keynote/Google Slides with a pre-designed brand look. Also use when the user asks to inline or embed a folder of PNGs/SVGs/fonts/CSS into an existing HTML file as base64 data URIs. Prefer this skill over `creating-presentations` (PowerPoint) whenever the final artefact is HTML. Prefer this skill over `web-artifacts-builder` for slide decks — that skill targets multi-component React artefacts, this one targets presentations.
---

# HTML Presentation

Build slide decks as one self-contained `.html` file. Arrow-key navigation, dark/light toggle, Earlybird brand defaults, all assets base64-inlined for portability.

## When to reach for this skill

- "Make me an HTML deck / slides / presentation"
- "Can you produce a single-file standalone presentation"
- "Turn this deck into something I can email / upload to Drive / share without assets"
- "Inline these images as base64 in the HTML"
- Brand-consistent presentations at Earlybird or EagleEye that need to be viewed in a browser

If the user wants a `.pptx`, use the `creating-presentations` skill instead. If the user wants a React artefact with state, use `web-artifacts-builder`.

## What this skill gives you

1. **A pre-styled template** (`assets/template/deck.html`) with Earlybird colors, Inter typography, dark/light theme toggle, keyboard navigation, progress bar, slide counter, **slide-navigator sidebar**, **slide search**, and **keyboard-shortcut help overlay** — ready to drop slides into.
2. **Layout patterns** (`references/layouts.md`) — copy-paste HTML for title, content, versus/comparison, stack, table, agenda, big-number list, three-card, two-column, three-column, checklist, and hero slides.
3. **Brand guardrails** (`references/brand-quick.md`) — the minimum-viable Earlybird brand facts you need to avoid the common mistakes.
4. **A workflow doc** (`references/workflow.md`) — the end-to-end recipe for scaffolding, previewing, and producing the standalone file.
5. **Interactive patterns** (`references/interactive-patterns.md`) — recipes for self-assessment quizzes, band classification, hand-rolled SVG radar charts, and paired logo swaps. Use this when the deck should contain a working tool (score-yourself, calculate-your-X) rather than only static slides.
6. **The inliner** (`scripts/inline_assets.py`) — Python script that turns an HTML file + its sibling asset folder into a single self-contained `.html` with everything embedded as base64 data URIs.

## How to use it

**Creating a new deck:**

1. Read `references/workflow.md` — it has the full recipe.
2. Read `references/layouts.md` — pick patterns from here rather than inventing CSS.
3. Copy the template into the target repo (typically `docs/presentations/<name>.html` plus a sibling `assets/` folder for logos).
4. Write slides as `<section class="slide">` blocks inside the `<div class="deck">`.
5. When ready for a portable version, run the inliner (see below).

**Only inlining an existing deck:**

Skip straight to the inliner. It works on any HTML file with local asset references, not just decks created from this template.

## The inliner

Script: `scripts/inline_assets.py`. Runs on plain CPython 3.9+ (no deps).

```bash
# Default: write <input>.standalone.html next to the input
python ~/.agents/skills/html-presentation/scripts/inline_assets.py \
  path/to/deck.html

# Choose an output path
python ~/.agents/skills/html-presentation/scripts/inline_assets.py \
  path/to/deck.html -o ~/Downloads/my-deck-standalone.html

# Dry-run: just report what would be inlined
python ~/.agents/skills/html-presentation/scripts/inline_assets.py \
  path/to/deck.html --check

# Only fonts (leave images linked)
python ~/.agents/skills/html-presentation/scripts/inline_assets.py \
  path/to/deck.html --font-only
```

The inliner handles:

- `<img src>`, `<script src>`, `<video src>`, `<audio src>`, `<source src>`, `<video poster>`
- `<link rel="stylesheet">` — the CSS body is embedded inline as a `<style>` block, and `url(...)` references inside it are resolved relative to the CSS file
- `<link rel="icon">` / `preload` / `apple-touch-icon`
- `url(...)` inside `<style>` blocks and `style="..."` attributes (fonts, background images, `@font-face`)

What it skips:

- Anything with a remote scheme (`http://`, `https://`, `data:`, `mailto:`, `tel:`, `#fragment`)
- Google Fonts `@import` and other remote stylesheets — they stay remote so the file still works when online. The default stylesheet has Inter via Google Fonts, which is fine for most uses.

It reports any local references it couldn't resolve so you can fix broken paths.

## Keyboard shortcuts (built in)

The template ships with a full keyboard layer. Nothing to wire up.

| Key                            | Effect                                          |
|--------------------------------|-------------------------------------------------|
| `←` `→` `Space` `h` `l` `j` `k`| Previous / next slide                           |
| `Home` `End` `gg` `G`          | First / last slide                              |
| `b`                            | Toggle the slide-navigator sidebar              |
| `/`                            | Open the sidebar and focus the search input    |
| `n` `N`                        | Next / previous search match                    |
| `?`                            | Show the keyboard-shortcut help overlay         |
| `d`                            | Toggle dark / light theme                       |
| `Esc`                          | Close overlay or sidebar                        |

Vim users: `h/j/k/l`, `gg`, `G`, `/`, `n`, `N` all work as expected. `gg` needs both `g` keystrokes within 500ms.

Sidebar titles are auto-extracted from each slide, in this priority: first `<h1>` → first `<h2>` → first `<h3>` → first `.kicker` → "Slide N". So as long as each slide has one of those near the top, the sidebar is self-maintaining.

Search matches:
- A pure number (e.g. `5`) jumps to that slide.
- Anything else is a case-insensitive substring search across slide titles.
- `Enter` in the search field jumps to the first match and closes the sidebar — ideal for a presenter moving between sections live.

The skill's layout patterns all use `h1`, `h2`, or `.kicker`, so you get sensible sidebar entries without any extra markup. If a slide is unusual (e.g. a pure SVG diagram), wrap it with a `.kicker` so it still shows up with a name.

## Writing good slides — general principles

Keep one idea per slide. If you catch yourself stacking three big components (a table + a callout + a three-card grid), split the slide.

Headlines go left or centre aligned, never right. Max 2 lines. If a headline is overflowing, move the overflow into body copy.

Use the `kicker` class for the small red eyebrow above a headline — it's the cheapest way to add context without stealing from the headline.

The `callout` class is your emphasis box. Use it for the "this is the key insight" moment, not as a default container for every paragraph.

The brand loves `--eb-red` (`#FD1A1B`), but a little goes a long way. One red element per slide is usually enough — the headline, a kicker, a key number, or a card border. If everything is red, nothing is.

Blue (`#319CFF`) and purple (`#A458BF`) are gradient-only. Never use them for solid fills or text. The template doesn't make it easy to misuse them, but be aware if you add custom styles.

Gradients are reserved for hero moments — opening slide, key differentiator, closing slide. Bottom-left or bottom-centre origin only.

## Confidentiality marker

External / investor decks need "strictly confidential" in the top right. The template ships with a generic `session-tag` slot — swap it for:

```html
<div class="session-tag">strictly confidential</div>
```

Internal decks can repurpose the tag for audience context ("AI Working Group · April 2026") or remove it entirely.

## Iterating on a deck

Work on the editable multi-file version during development (images stay as separate files — easier to swap). Only run the inliner when you need a portable artefact to share. Keep both in the repo if you want — they're both cheap.

## References

- `references/workflow.md` — the step-by-step recipe
- `references/layouts.md` — every available slide pattern with copy-paste HTML
- `references/brand-quick.md` — the Earlybird colours/typography/logo rules distilled to one page
- `references/interactive-patterns.md` — quiz / band classification / SVG radar / dual-logo swap / Oswald display font
- For the full brand spec (for anything the quick reference doesn't cover), see `~/code/skills/eb/brand-guidelines/earlybird-brand-guidelines.md`

## Known good example decks

Real decks built with this pattern that you can read for reference:

- `~/code/eagleeye/docs/presentations/signal-framework.html` — interactive self-assessment (18-question quiz + band classification + SVG radar), paired Earlybird/EagleEye logos with light-mode swap, Oswald used for dimension letters and big numbers. The patterns in `references/interactive-patterns.md` come from this deck.
- `~/code/eagleeye/.claude/worktrees/offsite-review/docs/presentations/augmented-vc.html` — 30+ slides, includes custom SVG, signal-grid, roadmap, mountain diagram
- `~/code/eagleeye/.claude/worktrees/offsite-review/docs/presentations/prompting-masterclass.html` — 19 slides, uses most of the layout patterns from `layouts.md`

All three have standalone counterparts produced by `inline_assets.py` — compare the editable and standalone versions to see what the inliner does to a real file.
