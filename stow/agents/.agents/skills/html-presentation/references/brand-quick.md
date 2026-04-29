# Earlybird brand — quick reference

This is the minimum you need to build a brand-consistent deck. For the
full spec, see `~/code/skills/eb/brand-guidelines/earlybird-brand-guidelines.md`.

## Colors

| Token             | Hex        | Use                                 |
|-------------------|------------|-------------------------------------|
| `--eb-red`        | `#FD1A1B`  | Primary brand — headlines, accents  |
| `--eb-dark`       | `#2D1A16`  | Dark card / mid-ground              |
| `--eb-darker`     | `#1a0f0d`  | Default body background (dark mode) |
| `--eb-light`      | `#F8FCFF`  | Body text / light-mode background   |
| `--eb-gray`       | `#8a8580`  | Muted / labels                      |
| `--eb-gray-light` | `#b5b0ab`  | Paragraph body                      |

Gradients (for object fills, not backgrounds):
`#FD1A1B` 100% → `#D94FF7` 40% → `#309BFF` 25% (bottom-left to top-right).

Blue (`#319CFF`) and purple (`#A458BF`) are gradient-only. Never use them
for text or solid backgrounds.

## Typography

**Brand fonts (default in this skill — the template ships them):**

- **Condensed Sans No.10** — headlines, ALL CAPS, 90% line height
- **Untitled Sans** — body copy, 140% line height, slight negative letter-spacing

The OTFs are bundled with the template under `assets/template/assets/fonts/`
and copy across automatically when you scaffold a new deck. The `@font-face`
declarations in `deck.html` point at that folder, and the inliner
base64-embeds the fonts into the standalone file. No configuration needed.

**Fallbacks only (safety net):**

Inter (body) and Oswald (condensed headlines) are Google-Fonts imports kept
in the CSS stack strictly as fallbacks — e.g. if a deck is ever rendered
somewhere the OTFs can't load. Don't pick Inter or Oswald as the default.
The stack is `'Untitled Sans', 'Inter', sans-serif` for body and
`'Condensed Sans No.10', 'Oswald', 'Untitled Sans', 'Inter', sans-serif`
for headlines — brand first, fallback second.

**Rules:**

- Headlines left-aligned by default (the template pins all slide content to
  the top-left rhythm). Centre-align only on hero / title slides where
  breaking the rhythm is the point. Never right-align.
- Headline size ≥ 2× body copy
- Max 2 lines per headline; overflow goes into body
- Copy 14–18 pt digital, 20–24 pt presentations

## Logo

- Position: far left, always leads
- Clear space: 1× logo height to edge, 2× to any other element
- Colors: Red (preferred), Off-Black, Off-White
- Never stretch, rotate, or recolor outside those three

**Default in this skill — Earlybird + EagleEye pairing.** The template ships
Earlybird Red (works on both dark and light backgrounds, no swap needed)
and the EagleEye eagle in both a light-for-dark-background and
dark-for-light-background variant. The pair is the EagleEye-repo default
because that's where most decks built from this template live.

If a deck isn't an EagleEye deck (e.g. a pure Earlybird investor deck),
delete both EagleEye `<img>` tags and the `<span class="sep"></span>` from
the `.logo` div in the scaffolded HTML. That leaves a clean Earlybird-only
wordmark in the corner.

Logo assets ship with this skill under `assets/template/assets/`
(`Earlybird_Logo_RGB_Red.svg`, `Earlybird_Logo_RGB_OffBlack.svg`,
`Earlybird_Logo_RGB_White.svg`, `eagleeye-logo.png`,
`eagleeye-logo-dark.png`).

## Gradient rules

- Use sparingly — opening slide, key differentiator, close
- Bottom-left or bottom-centre origin only
- Never over text
- One gradient style per layout

## Confidentiality marker

External/investor decks should show `strictly confidential` in the top
right on the title slide. Internal decks can omit it — or replace with a
session tag (e.g. "AI Working Group · April 2026").

## Common mistakes to reject

- Gradient starting from the left
- Small light type under a bold headline (noise)
- Right-aligned text
- Blue/purple used outside a gradient
- Headlines longer than 2 lines
- Multiple gradient styles mixed on one slide
- Missing or recoloured logo
