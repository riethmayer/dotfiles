# Slide layout patterns

Each pattern is a copy-paste block. Drop into the `<div class="deck">` in
`assets/template/deck.html`. All classes are already styled in the template.

## Title slide

```html
<section class="slide">
  <div class="kicker">Context / Audience</div>
  <h1>Main title<br><span class="red">second line</span></h1>
  <p class="subtitle">One-line hook.</p>
  <p class="subtitle" style="font-size:0.95rem;margin-top:2rem;">Optional attribution.</p>
</section>
```

## Simple content slide (heading + bullets)

```html
<section class="slide">
  <h2>Slide heading</h2>
  <p class="big">One-sentence takeaway.</p>
  <ul>
    <li>Supporting point</li>
    <li>Supporting point</li>
  </ul>
</section>
```

## Callout / emphasis box

Use for the "this is the key insight" moment.

```html
<section class="slide">
  <h2>Heading</h2>
  <div class="callout">
    <p>Core insight in one or two sentences. <strong>Emphasis</strong> inside is light on the eye.</p>
  </div>
</section>
```

## Versus / 10× comparison

Two-card split with a bold emphasised middle. Great for before/after.

```html
<section class="slide">
  <div class="kicker">Framing line</div>
  <h2>The headline conclusion</h2>
  <div class="versus">
    <div class="versus-card a">
      <div class="label">Left label</div>
      <h4>Short claim.</h4>
      <p>Body.</p>
      <p class="muted">Qualifier.</p>
    </div>
    <div class="versus-gap">10×<small>gap</small></div>
    <div class="versus-card b">
      <div class="label">Right label</div>
      <h4>Short claim.</h4>
      <p>Body.</p>
      <p class="red" style="font-weight:600;">Kicker line.</p>
    </div>
  </div>
</section>
```

## Stack diagram

A vertical stack with level labels — use for hierarchies, layers, or
"stack not menu" points.

```html
<section class="slide">
  <h2>Not a menu. A stack.</h2>
  <p class="big">Each layer makes the layers above it possible.</p>
  <div class="stack">
    <div class="stack-item">
      <div>
        <div class="level">Layer 4 · Top</div>
        <div class="name">Layer name</div>
      </div>
      <div class="desc">One-line description</div>
    </div>
    <!-- repeat <div class="stack-item"> for each layer -->
  </div>
</section>
```

## Table (comparison / matrix)

```html
<section class="slide">
  <h2>Comparison</h2>
  <table>
    <thead><tr><th>Column A</th><th>Column B</th><th>Column C</th></tr></thead>
    <tbody>
      <tr><td><strong>Row label</strong></td><td>Value</td><td>Value</td></tr>
    </tbody>
  </table>
</section>
```

## Time-block agenda

```html
<section class="slide">
  <h2>Session agenda</h2>
  <table>
    <thead><tr><th>Time</th><th>Block</th><th>Format</th></tr></thead>
    <tbody>
      <tr>
        <td style="white-space:nowrap;"><strong>0:00 – 0:15</strong></td>
        <td>Opening block</td>
        <td class="muted">Walkthrough</td>
      </tr>
    </tbody>
  </table>
</section>
```

## Big-number list (ol.big-num)

Numbered list with red oversized numerals — good for the "five primitives"
type slide.

```html
<section class="slide">
  <h2>The N primitives</h2>
  <ol class="big-num">
    <li><strong>Primitive name</strong> &mdash; short explanation.</li>
    <li><strong>Primitive name</strong> &mdash; short explanation.</li>
  </ol>
</section>
```

## Three-thing cards

Three equal cards with a numeric badge. Good for "one thing this week" or
"three takeaways".

```html
<section class="slide">
  <h2>Three takeaways</h2>
  <div class="things">
    <div class="thing"><div class="num">1</div><h4>First thing.</h4><p>Body copy.</p></div>
    <div class="thing"><div class="num">2</div><h4>Second thing.</h4><p>Body copy.</p></div>
    <div class="thing"><div class="num">3</div><h4>Third thing.</h4><p>Body copy.</p></div>
  </div>
</section>
```

## Two-column content

```html
<section class="slide">
  <h2>Two columns</h2>
  <div class="cols">
    <div>
      <h3 class="red">Left heading</h3>
      <p>Body.</p>
    </div>
    <div>
      <h3 class="red">Right heading</h3>
      <p>Body.</p>
    </div>
  </div>
</section>
```

## Three-column content

Use `.cols-3` instead of `.cols`.

## Checklist (homework / action items)

```html
<section class="slide">
  <div class="kicker">Month 1</div>
  <h2>This month's deliverables</h2>
  <ul class="checklist">
    <li>First action item</li>
    <li>Second action item</li>
  </ul>
  <div class="callout">
    <p><strong>Deliverable:</strong> what you should have at the end of the month.</p>
  </div>
</section>
```

## Full-bleed / hero statement

For high-drama pause slides.

```html
<section class="slide">
  <div class="kicker">Prompt 0 · The Human Prompt</div>
  <h1 style="font-size:3.2rem;">This is not a prompt.<br><span class="red">It's a thinking exercise.</span></h1>
  <p class="subtitle">Supporting one-liner.</p>
</section>
```

## Mixing patterns

Patterns compose freely. A common layout is:

- Top: `kicker` + `h2`
- Middle: `versus` or `stack` or `things`
- Bottom: `callout` with the takeaway

Keep one dominant element per slide. If you find yourself stacking three
big components, split the slide.

## Typography tokens quick reference

| Class     | Purpose                                |
|-----------|----------------------------------------|
| `kicker`  | Small red eyebrow above a headline     |
| `big`     | Large body takeaway under a heading    |
| `huge`    | Display-size emphasis paragraph        |
| `subtitle`| Light-weight under-headline text       |
| `muted`   | Gray helper text                       |
| `red`     | Brand-red inline color                 |

## Color overrides

The template supports a light-mode toggle (press `D`). If you hardcode
colors, use the CSS variables (`var(--eb-light)`, `var(--eb-gray-light)`,
etc.) so the slide inverts correctly when the theme flips.
