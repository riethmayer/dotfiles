# Interactive patterns

Slides aren't always passive. A presentation can contain a working tool — a self-assessment, a calculator, a small simulation — as long as it runs client-side and survives the inliner. This reference covers the patterns the SIGNAL framework deck proved out: questionnaires, band classification, and hand-rolled SVG radar charts, with no external libraries.

Why build them this way: the whole skill exists to produce **one portable HTML file**. A chart library or React dependency would either break the inliner or require a build step. Every pattern here is vanilla JS + inline SVG, chosen so the deck still works when emailed, opened offline, or uploaded to Drive.

## When to reach for an interactive slide

- The deck argues for a framework, and letting the audience score themselves against it turns a monologue into a diagnostic
- There's a simple calculation the audience would otherwise try to do in their head (ROI, readiness, fit)
- You want the deck to have a "try it now" moment late in the narrative, so the takeaway lands with personal data rather than a generic conclusion

One interactive per deck is usually plenty. Two or three inflate the file, dilute the story, and make the inliner job harder.

## Pattern 1 — Self-assessment questionnaire

A form slide where the audience answers N questions per dimension on a 1–5 scale, then sees a computed result. Data-driven: add a new dimension by pushing one more object into the `QUIZ` array.

**Data shape:**

```js
const QUIZ = [
  { letter: 'S', name: 'Stance', questions: [
    'Can every team member articulate what AI use is allowed vs. prohibited at the firm?',
    'Is the AI policy maintained as a living document with a named owner?',
    'Do people feel safe experimenting with AI within the stated guardrails?',
  ]},
  // ...more dimensions
]
```

**Slide markup** — a container the render function fills in:

```html
<section class="slide" id="slide-quiz">
  <div class="kicker">Try it</div>
  <h2>Score your firm</h2>
  <p>Three questions per dimension, scored <strong>1&ndash;5</strong> against the maturity ladders you just saw. Runs entirely in your browser &mdash; nothing is uploaded.</p>
  <form id="quiz-form" class="quiz"></form>
  <div id="quiz-result" style="display:none;"></div>
</section>
```

That "nothing is uploaded" line matters. A self-assessment without it reads as a lead-capture form, not an in-the-room tool. State it plainly.

**Rendering** — one grid cell per dimension, radio scale per question:

```js
function renderQuiz() {
  const form = document.getElementById('quiz-form')
  if (!form || form.dataset.rendered) return
  const grid = document.createElement('div')
  grid.className = 'quiz-grid'
  QUIZ.forEach((dim, di) => {
    const box = document.createElement('div')
    box.className = 'quiz-dim'
    const qs = dim.questions.map((q, qi) => {
      const name = `q-${di}-${qi}`
      const scale = [1,2,3,4,5].map(n =>
        `<label class="scale-pos"><input type="radio" name="${name}" value="${n}" required><span>${n}</span></label>`
      ).join('')
      return `<div class="quiz-q">${q}</div><div class="quiz-scale">${scale}</div>`
    }).join('')
    box.innerHTML = `<h4><span class="letter">${dim.letter}</span> ${dim.name}</h4>${qs}`
    grid.appendChild(box)
  })
  form.appendChild(grid)
  const actions = document.createElement('div')
  actions.className = 'quiz-actions'
  actions.innerHTML = `<button type="submit" class="btn">Show my radar</button><button type="button" class="btn ghost" id="quiz-reset">Reset</button><span class="quiz-hint">1 = not at all &middot; 5 = fully embedded</span>`
  form.appendChild(actions)
  form.dataset.rendered = '1'
  form.addEventListener('submit', e => { e.preventDefault(); computeResult() })
  document.getElementById('quiz-reset').addEventListener('click', () => form.reset())
}
```

The `dataset.rendered` guard makes the function idempotent — safe to call on every slide change.

**Computing the score:**

```js
function computeResult() {
  const form = document.getElementById('quiz-form')
  const scores = QUIZ.map((dim, di) => {
    const vals = dim.questions.map((_, qi) => {
      const el = form.querySelector(`input[name="q-${di}-${qi}"]:checked`)
      return el ? parseInt(el.value, 10) : null
    })
    if (vals.some(v => v == null)) return null
    return vals.reduce((a, b) => a + b, 0) / vals.length
  })
  if (scores.some(s => s == null)) return
  renderResult(scores)
}
```

Per-dimension score is the mean of its questions. Overall score is the mean of dimension means (not the mean of all questions) — this weights each dimension equally regardless of how many questions it has.

## Pattern 2 — Band classification

Map a numeric score into a named band with a prose description. The pattern is a sorted array of thresholds + a linear scan:

```js
const BANDS = [
  { max: 1.5, label: 'No strategy', desc: 'Personal productivity for whoever discovers it. No firm-level capability.' },
  { max: 2.5, label: 'Aware',       desc: 'Tools deployed, some policy exists, no integration with workflows or data.' },
  { max: 3.5, label: 'Operational', desc: '1–2 workflows redesigned, data connected, governance in place.' },
  { max: 4.5, label: 'Systematic',  desc: 'All domains covered, outcome attribution working, compounding moats.' },
  { max: 5.01, label: 'Embedded',   desc: 'Inseparable from how the firm operates. Structural alpha measurable.' },
]

function bandFor(score) { return BANDS.find(b => score < b.max) || BANDS[BANDS.length - 1] }
```

Five bands is a common sweet spot — distinct enough to feel categorical, coarse enough to be memorable. Use the `max: 5.01` trick on the top band so a perfect score still matches.

## Pattern 3 — Binding constraints

Surface the two lowest dimensions as "this is what to fix first". This turns the result from a score into a recommendation:

```js
const ranked = scores.map((s, i) => [i, s]).sort((a, b) => a[1] - b[1])
const lowTwo = new Set([ranked[0][0], ranked[1][0]])
// Use lowTwo to highlight dim-row elements, list names in a "binding constraints" sentence, etc.
```

"Binding constraint" (a loan from optimization) reads better than "your weakest areas" — it's descriptive, not judgemental.

## Pattern 4 — Result panel with "Copy as markdown"

Two columns: numbers on the left, radar on the right. Each dimension gets a row with a mini-bar and its score. Offer a markdown export so the audience can paste into a doc or Slack:

```js
const md = [
  `# SIGNAL self-assessment`,
  ``,
  `**Overall: ${overall.toFixed(1)} / 5.0 — ${band.label}**`,
  ``,
  ...QUIZ.map((d, i) => `- ${d.letter} · ${d.name}: ${scores[i].toFixed(1)}`),
  ``,
  `Binding constraints: ${QUIZ[ranked[0][0]].name}, ${QUIZ[ranked[1][0]].name}`,
].join('\n')
navigator.clipboard.writeText(md).then(() => { /* flash the button text to "Copied" for 1.5s */ })
```

Plain markdown — not a URL, not a QR code, not an email form. That's the point: the audience owns the output, and the deck doesn't phone home.

## Pattern 5 — Hand-rolled SVG radar

No chart library. The radar is a function of an array of scores, drawn as inline SVG that inherits the theme's CSS variables.

```js
function radarSvg(scores) {
  const size = 460, cx = size/2, cy = size/2, r = size/2 - 80
  const n = QUIZ.length
  const angleFor = i => -Math.PI/2 + (i * 2*Math.PI / n)
  const pointAt = (i, v) => {
    const a = angleFor(i)
    const rr = (v / 5) * r
    return [cx + Math.cos(a) * rr, cy + Math.sin(a) * rr]
  }
  const rings = [1,2,3,4,5].map(v => {
    const pts = Array.from({length: n}, (_, i) => pointAt(i, v).join(',')).join(' ')
    return `<polygon class="grid-ring" points="${pts}"/>`
  }).join('')
  const axes = Array.from({length: n}, (_, i) => {
    const [x, y] = pointAt(i, 5)
    return `<line class="axis" x1="${cx}" y1="${cy}" x2="${x}" y2="${y}"/>`
  }).join('')
  const labels = QUIZ.map((d, i) => {
    const [x, y] = pointAt(i, 5)
    const dx = x - cx, dy = y - cy
    const ox = cx + dx * 1.14, oy = cy + dy * 1.14 + 5
    const anchor = Math.abs(dx) < 2 ? 'middle' : (dx > 0 ? 'start' : 'end')
    return `<text class="axis-label" x="${ox.toFixed(1)}" y="${oy.toFixed(1)}" text-anchor="${anchor}">${d.letter}</text>`
  }).join('')
  const pts = scores.map((s, i) => pointAt(i, s))
  const shape = `<polygon class="data-shape" points="${pts.map(p => p.join(',')).join(' ')}"/>`
  const dots = pts.map(([x,y]) => `<circle class="data-point" cx="${x.toFixed(1)}" cy="${y.toFixed(1)}" r="3.5"/>`).join('')
  return `<svg class="radar" viewBox="0 0 ${size} ${size}" role="img" aria-label="Radar chart">${rings}${axes}${labels}${pts.length ? shape : ''}${dots}</svg>`
}
```

Key geometry decisions:

- **Start at top** (`-Math.PI/2`) and go clockwise — matches the "clock face" reading order most audiences expect
- **Ring polygons, not circles** — they visually connect to the axes and make the radar feel structural
- **Label offset `* 1.14`** — outside the outermost ring by a consistent fraction, so labels don't overlap the shape at max scores
- **Anchor by quadrant** — `start`/`end`/`middle` based on whether the label sits right-of-centre, left-of-centre, or on the vertical axis

**Styling** — style the SVG via CSS so the radar participates in the dark/light toggle:

```css
.radar { width: 100%; max-width: 28rem; height: auto; }
.radar .grid-ring { fill: none; stroke: rgba(255,255,255,0.08); stroke-width: 1; }
html.light .radar .grid-ring { stroke: rgba(0,0,0,0.08); }
.radar .axis { stroke: rgba(255,255,255,0.1); stroke-width: 1; }
html.light .radar .axis { stroke: rgba(0,0,0,0.1); }
.radar .axis-label { fill: var(--eb-light); font-family: 'Oswald', sans-serif; font-size: 14px; font-weight: 700; text-transform: uppercase; }
.radar .data-shape { fill: rgba(253,26,27,0.22); stroke: var(--eb-red); stroke-width: 2; }
.radar .data-point { fill: var(--eb-red); }
```

The fill is red at 22% opacity — enough to read as a region, not so much that it fights the rings.

## Display type inside the result panel

Score numbers, axis labels, and dimension letters (S-I-G-N-A-L) want condensed display type, same as headlines. The brand font for this is **Condensed Sans No.10**, which the template already loads — just reuse the headline stack:

```css
.radar .axis-label,
.result-side .band-score,
.result-side .dim-row .val {
  font-family: 'Condensed Sans No.10', 'Oswald', 'Untitled Sans', 'Inter', sans-serif;
  font-weight: 900;
  text-transform: uppercase;
}
```

Oswald sits in the fallback position for the same reason it does elsewhere in the template — if the OTF ever fails to load, a condensed Google sans is closer to the brand look than reverting to Untitled Sans at the same size. Don't target Oswald directly; target the brand font and let the stack degrade.

## Adding more theme-swapped images

The template already ships the Earlybird + EagleEye logo pair with the
`.logo-dark-mode` / `.logo-light-mode` class swap wired up — see
`references/brand-quick.md` for the logo defaults. If a deck introduces
another image that needs a light/dark variant (e.g. a co-brand mark, a
sponsor logo), reuse the same class convention: name by the theme the
image is shown in, not by the image's own colour. CSS-only swap, no JS,
and the inliner handles both sources identically.

## Keep the slide hook short

The interactive is a tool, not an argument. Let the preceding slides do the teaching; the quiz slide just invites the audience to try it on themselves. The SIGNAL deck's quiz-slide copy is three lines: kicker, headline, one-sentence instruction. That's the whole intro.
