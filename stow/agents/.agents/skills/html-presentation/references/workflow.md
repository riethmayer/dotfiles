# Workflow: creating a new self-contained HTML deck

## 1. Scaffold

Copy the template into the project where the deck lives.

```bash
# From the target repo
mkdir -p docs/presentations
cp ~/.agents/skills/html-presentation/assets/template/deck.html \
   docs/presentations/<deck-name>.html
cp -r ~/.agents/skills/html-presentation/assets/template/assets \
   docs/presentations/
```

Putting the HTML file at `docs/presentations/<deck-name>.html` and the
assets under `docs/presentations/assets/` keeps relative `src="assets/…"`
paths stable whether you're viewing the editable version or running the
inliner.

The `assets/` folder you just copied contains both the Earlybird logos and
the brand font OTFs (`assets/fonts/`). Don't skip the font copy — the
template's `@font-face` rules resolve against that folder. Without them,
the deck falls back to Inter / Oswald, which are in the CSS stack as
safety-nets, not defaults.

## 2. Edit

Open the HTML file. The template ships with:

- A title slide and one placeholder content slide
- All CSS classes pre-styled (see `references/layouts.md` for every
  available pattern)
- Arrow-key + click navigation, `D` toggles light mode, a progress bar,
  and a slide counter

Replace the `<section class="slide">` blocks with your content. Build each
slide with one of the patterns from `layouts.md`. Keep one dominant
element per slide — if you stack three, split the slide.

## 3. Preview locally

Just open the file in a browser:

```bash
open docs/presentations/<deck-name>.html
```

Everything is static; no dev server needed. Once the deck loads:

- `b` toggles a left sidebar that lists every slide with auto-extracted titles. Click to jump.
- `/` opens the sidebar and focuses the search input. Type text to fuzzy-filter titles, or type a number to jump to a slide directly. `Enter` jumps to the first match.
- `?` shows an overlay listing every shortcut. `Esc` closes it.

Titles come from each slide's first `<h1>` → `<h2>` → `<h3>` → `.kicker`. If a slide has none of those (e.g. a pure diagram slide), add a `.kicker` so it's labelled in the sidebar.

## 4. Produce a standalone version

When you want a single portable file (email, flash drive, Drive upload),
run the inliner:

```bash
python ~/.agents/skills/html-presentation/scripts/inline_assets.py \
  docs/presentations/<deck-name>.html \
  -o ~/Downloads/<deck-name>-standalone.html
```

The inliner:

- Embeds every `<img>`, `<link rel="icon">`, `<script src>`, poster, and
  CSS `url(...)` reference it can resolve locally
- Embeds linked stylesheets inline as `<style>` blocks
- Leaves remote URLs (http/https, data, mailto) alone
- Reports anything it couldn't resolve

**Dry-run** before overwriting to see what would happen:

```bash
python ~/.agents/skills/html-presentation/scripts/inline_assets.py \
  docs/presentations/<deck-name>.html --check
```

**Font-only** (keeps images linked but inlines OTF/WOFF/TTF):

```bash
python ~/.agents/skills/html-presentation/scripts/inline_assets.py \
  docs/presentations/<deck-name>.html --font-only
```

## 5. Ship both versions

Keep the editable multi-file version in the repo for future diffs. Share
the `-standalone.html` for anyone who needs to open it without pulling
the repo.

## Naming conventions in the EagleEye repo

The canonical place is `docs/presentations/`, which already has
`AGENTS.md` with the Earlybird presentation guide. Prefix with a date if
the deck is tied to a specific event: `2026-04-16-augmented-vc.html`.
