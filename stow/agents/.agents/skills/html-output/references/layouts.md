# Layout patterns

Copy-paste HTML snippets for composable document patterns. These are **a library, not a structure** — pick what the content needs, skip what it doesn't.

The brand chrome (colors, typography, light/dark, sidebar, keyboard layer) comes from `assets/template/earlybird-base.css` (XS artifacts) or `assets/template/doc.html` (M/L artifacts). These patterns layer on top — they all reference the same CSS variables, so they look coherent whichever scaffold you start from.

**When you need the deeper craft** — bold custom aesthetic direction, component thinking outside Earlybird brand, interactive React state — reach for the companion skills (`frontend-design`, `web-artifacts-builder`). These patterns are for the Earlybird-shelled common case.

## Table of contents

1. [Header + headline + handoff](#header)
2. [Tracks overview (2-column)](#tracks)
3. [Status cards (closed / open)](#status)
4. [Gap card — the main unit](#gap)
5. [Quote variants (Max / Daniel / transcript)](#quotes)
6. [Decision banner](#decided)
7. [Options grid (chosen / declined)](#options)
8. [Before/after diff — paragraph](#diff-para)
9. [Before/after diff — TOC / structural](#diff-toc)
10. [Per-group grid (N cohorts)](#per-group)
11. [Timeline (horizontal milestones)](#timeline)
12. [Owners grid](#owners)
13. [Next steps (multi-column)](#steps)
14. [Parked grid (future workstreams)](#parked)
15. [Footer](#footer)

---

## Header + headline + handoff <a id="header"></a>

The first block. Title, subtitle, one-sentence headline banner, optional handoff callout.

```html
<header>
  <div class="classification">Strictly Confidential · Internal</div>
  <div class="brand">earlybird</div>
  <h1>Doc title — concise, decision-oriented</h1>
  <div class="subtitle">Post-alignment memo · 15 May 2026 · Audience names</div>
  <div class="headline">
    <strong>Headline:</strong> One sentence that gives the reader the punchline before they read anything else. <strong>Bold the load-bearing facts.</strong>
  </div>
  <div class="handoff">
    <strong>Author handoff (optional).</strong> Use when authorship or ownership is transitioning — name the new owner, name the role of the prior owner, set expectations. Skip if not relevant.
  </div>
</header>
```

**When to use:** every doc has the header + classification + h1 + subtitle. The headline banner is a strong default — gives readers the answer up front. The handoff callout is situational.

**Writing tip:** the H1 should describe the *decision*, not the topic. "Claude DPIA — where we are, what's left" beats "Claude DPIA Alignment Notes".

---

## Tracks overview (2-column) <a id="tracks"></a>

For docs covering two parallel workstreams or two halves of a decision.

```html
<section class="section">
  <h2 class="section-title">The shape of the work</h2>
  <div class="tracks">
    <div class="track-card track-a">
      <div class="track-status">Track A · status badge</div>
      <div class="track-title">Track A — short headline</div>
      <div class="track-desc">One-line scope description</div>
      <div class="track-detail">
        Paragraph context. <strong>Bold the load-bearing fact.</strong>
      </div>
    </div>
    <div class="track-card track-b">
      <div class="track-status">Track B · status badge</div>
      <div class="track-title">Track B — short headline</div>
      <div class="track-desc">One-line scope description</div>
      <div class="track-detail">Paragraph context.</div>
    </div>
  </div>
</section>
```

`track-a` gets a green left border (resolved / fast path). `track-b` gets orange (in flight / slow path). Skip this section entirely if the work isn't naturally split into two tracks.

---

## Status cards — closed items · open decisions <a id="status"></a>

Pair of cards (or solo) showing recently closed items + open decisions. Goes near the top, before the main content, so readers have the state-of-play before diving in.

```html
<section class="section">
  <h2 class="section-title">Closed items · open decisions</h2>
  <div class="status-grid">
    <div class="status-card closed-card">
      <div class="status-label">Closed · May 8</div>
      <div class="status-title">What was closed — short headline</div>
      <div class="status-detail">
        Two-to-four sentences. Lead with the decision or acceptance, then the implication for downstream work. <strong>Bold the consequence.</strong>
      </div>
    </div>
    <div class="status-card open-card">
      <div class="status-label">Open · area</div>
      <div class="status-title">What's still open — phrased as a question</div>
      <div class="status-detail">
        Frame the open decision, list the options, name the decision owner and target date.
      </div>
    </div>
  </div>
</section>
```

**Variants:**
- All-closed: use two `closed-card` cards
- All-open: use two `open-card` cards
- Re-title to "Closed items — context for v0.5" or similar if framing helps

---

## Gap card — the main unit <a id="gap"></a>

The reusable building block. A gap-card has: header (number + title + severity badge), quotes (context), decision banner (once decided), options grid (the deliberation), diff (the result). All sub-blocks are optional except the header.

```html
<div class="gap">
  <div class="gap-header">
    <div class="gap-number">1</div>
    <div class="gap-title-row">
      <div class="gap-title">Short headline of the gap / decision</div>
      <div class="gap-sub">Provenance line — where it came from, why it matters</div>
    </div>
    <div class="severity sev-decided">Decided · Option A</div>
  </div>
  <div class="gap-body">

    <div class="gap-quotes">
      <!-- one or more .quote blocks; see Quote variants -->
    </div>

    <div class="decided-banner">
      <!-- the decision; see Decision banner -->
    </div>

    <div class="options-title">Options considered</div>
    <div class="options">
      <!-- A/B/C choices; see Options grid -->
    </div>

    <div class="options-title">Before / after — section X</div>
    <div class="diff">
      <!-- side-by-side diff; see Before/after diff -->
    </div>

  </div>
</div>
```

**Severity badge variants** (the class on `.severity`):
- `sev-blocker` — red — active go-live blocker
- `sev-major` — orange — major item, not yet resolved
- `sev-cleanup` — gray — minor cleanup
- `sev-decision` — yellow — pending decision
- `sev-decided` — green — decision made
- `sev-resolved` — green — fully resolved

Use the badge to communicate state at a glance. A doc full of green badges reads as "we have a plan"; red badges read as "blockers remain".

---

## Quote variants <a id="quotes"></a>

Three styles, distinguished by who's speaking and how the quote was captured.

```html
<!-- Written feedback from external party (e.g. DPO) -->
<div class="quote quote-max">
  <div class="quote-attrib">Speaker — date / source</div>
  Direct quote with the load-bearing phrase preserved.
</div>

<!-- Written response from internal author -->
<div class="quote quote-daniel">
  <div class="quote-attrib">Author — version / source</div>
  Their response, lightly cleaned.
</div>

<!-- "From the room" — meeting transcript quote -->
<div class="quote quote-transcript">
  <div class="quote-attrib">From the room — 13 May (Speaker, context)</div>
  <p>"Live quote, lightly cleaned for readability. <span class="speaker">Bold the load-bearing phrase</span> so it pops on scan."</p>
  <p style="margin-top: 8px;"><span class="speaker">Second speaker:</span> "Second beat if it adds to the same point."</p>
</div>
```

`.quote-max` has a red left border (external authority pushback). `.quote-daniel` has gray (internal response). `.quote-transcript` has orange + italic (live meeting capture).

**Writing tip for transcript quotes:** Granola-style auto-transcripts are messy. Clean for readability but preserve the speaker's voice. Use `[brackets]` for clarifying inserts. Don't over-polish — the quote should sound like the actual speaker.

---

## Decision banner <a id="decided"></a>

The green callout marking a decision. Sits between the quotes and the options grid.

```html
<div class="decided-banner">
  <span class="decided-tag">Decided 14 May</span> <strong>Option A</strong> — one-sentence rationale. Mention the date, owner if not Jan, and the key reasoning. Inherit framings from earlier gaps where they apply.
</div>
```

**Variant — pending review (yellow):**

```html
<div class="decided-banner" style="border-left-color: var(--yellow); background: rgba(202,138,4,0.08);">
  <span class="decided-tag" style="background: var(--yellow); color: var(--bg)">To review</span> <strong>Open — no decision yet.</strong> Describe what's pending and who drives the review.
</div>
```

---

## Options grid <a id="options"></a>

Lists A/B/C/D options with chosen/declined visual states. Use even when the decision is made — the audit trail shows the deliberation.

```html
<div class="options">
  <div class="option chosen">
    <div class="option-letter">A</div>
    <div>
      <div class="option-text"><strong>Headline of option A.</strong> One sentence describing it.</div>
      <div class="option-meta">Cost / risk · <span class="recommend-badge" style="background:var(--green)">Chosen</span></div>
    </div>
  </div>
  <div class="option declined">
    <div class="option-letter">B</div>
    <div>
      <div class="option-text"><strong>Headline of option B.</strong> Description.</div>
      <div class="option-meta">Cost / risk · Why rejected</div>
    </div>
  </div>
  <div class="option">
    <div class="option-letter">C</div>
    <div>
      <div class="option-text"><strong>Headline of option C.</strong> Description.</div>
      <div class="option-meta">Cost / risk</div>
    </div>
  </div>
</div>
```

**State classes:**
- `.chosen` — green left border + tinted background — picked option
- `.declined` — dimmed at 55% opacity — explicitly rejected
- (no state) — neutral / still on the table

**For pre-decision docs:** use `.recommend` on the leading option with a "Path" badge in red.

---

## Before/after diff — paragraph <a id="diff-para"></a>

The signature pattern. Side-by-side compare of current text vs proposed text. Use when the deliverable is a paragraph rewrite.

```html
<div class="diff">
  <div class="diff-side before">
    <div class="diff-label">Before <span class="diff-loc">v0.4 §X.Y</span></div>
    <div class="diff-text">
      <p>"The literal current text in quotes. Preserve the original wording so reviewers see what's changing."</p>
      <span class="annot">Annotation: what's wrong with the current text, which comment / feedback flagged it.</span>
    </div>
  </div>
  <div class="diff-side after">
    <div class="diff-label">After <span class="diff-loc">v0.5 §X.Y</span></div>
    <div class="diff-text">
      <p><strong>§X.Y New paragraph heading.</strong> The proposed replacement text. Multiple paragraphs allowed.</p>
      <p>Use <code>code spans</code> for file paths or identifiers.</p>
      <p><strong>Sub-headers in bold</strong> for multi-part replacements.</p>
      <span class="annot">Annotation: what reviewer must validate before this lands.</span>
    </div>
  </div>
</div>
```

The before column gets a red tint, after gets green. On narrow screens the columns stack.

---

## Before/after diff — TOC / structural <a id="diff-toc"></a>

For reorders, additions, removals — where the change is structural rather than paragraph-level.

```html
<div class="diff">
  <div class="diff-side before">
    <div class="diff-label">Before <span class="diff-loc">v0.4 TOC</span></div>
    <div class="diff-text toc-list">
      <ol>
        <li class="lvl1">§0 &nbsp;Section name (stays)</li>
        <li class="lvl1"><span class="stays-here">§3 &nbsp;Section in old position</span></li>
        <li class="lvl1"><span class="moved">§4 &nbsp;Section that will move</span></li>
        <li class="lvl1"><span class="removed">§5 &nbsp;Section that will be removed</span></li>
      </ol>
      <span class="annot">Annotation: what's structurally wrong.</span>
    </div>
  </div>
  <div class="diff-side after">
    <div class="diff-label">After <span class="diff-loc">v0.5 reordered TOC</span></div>
    <div class="diff-text toc-list">
      <ol>
        <li class="lvl1">§0 &nbsp;Section name</li>
        <li class="lvl1"><span class="added">§3 &nbsp;Section in new position</span> <span style="font-weight:400;color:var(--text-dim)">(was §4)</span></li>
        <li class="lvl1"><span class="stays-here">§4 &nbsp;Section that stays here</span></li>
      </ol>
      <span class="annot">Annotation: cross-reference cleanup needed.</span>
    </div>
  </div>
</div>
```

**Span classes inside `.toc-list`:**
- `.stays-here` — red — the anchor item the others move around
- `.moved` — green — item that changed position
- `.removed` — strikethrough + dim — item extracted / deleted
- `.added` — green — item in its new position
- `.lvl1`, `.lvl2` — heading level for indent

---

## Per-group grid <a id="per-group"></a>

3-column breakdown when a decision has different applications across cohorts.

```html
<div class="group-grid">
  <div class="group-card">
    <div class="group-label">Group 1 · cohort name</div>
    <div class="group-safeguard">The safeguard for this cohort. Use <strong>bold</strong> for emphasis. Use <em>em</em> for sub-headers.</div>
  </div>
  <div class="group-card">
    <div class="group-label">Group 2 · cohort name</div>
    <div class="group-safeguard"><strong>NEW POLICY:</strong> The new commitment for this cohort.</div>
  </div>
  <div class="group-card">
    <div class="group-label">Group 3 · cohort name</div>
    <div class="group-safeguard">Description for the third cohort.</div>
  </div>
</div>
```

Top border colors rotate green / red / orange for the three cards automatically. Use sparingly — once or twice per doc max.

---

## Timeline <a id="timeline"></a>

Horizontal milestone row with done / now / future states.

```html
<section class="section">
  <h2 class="section-title">Timeline</h2>
  <div class="timeline-wrap">
    <div class="timeline">
      <div class="t-node">
        <div class="t-date">Apr 29</div>
        <div class="t-dot done"></div>
        <div class="t-label">First milestone — past, completed</div>
      </div>
      <div class="t-node">
        <div class="t-date">May 15 · today</div>
        <div class="t-dot now"></div>
        <div class="t-label">Current milestone — pulsing red dot</div>
      </div>
      <div class="t-node">
        <div class="t-date">~May 29</div>
        <div class="t-dot"></div>
        <div class="t-label">Future milestone — regular red dot</div>
      </div>
    </div>
  </div>
</section>
```

**Dot states:**
- `.done` — green — past, completed
- `.now` — pulsing red, larger — current
- (no class) — red — future

Use 3-5 nodes. More than 5 gets cluttered. Use approximate dates (`~May 29`) when the future is fuzzy.

---

## Owners grid <a id="owners"></a>

4-column person cards. Each card has a top border in a category color, name, role, and a 1-3 sentence detail.

```html
<section class="section">
  <h2 class="section-title">Owners</h2>
  <div class="people">
    <div class="person" style="border-top-color: var(--red);">
      <div class="person-name">Person Name</div>
      <div class="person-role">Role · Tag</div>
      <div class="person-obs">What they own. <strong>Bold a key date or commitment</strong> so it stands out.</div>
    </div>
    <!-- repeat for each owner -->
  </div>
</section>
```

**Color convention:** red for the primary owner, orange for the deputy / next-most-load, green for adjacent owner, gray for supporting / part-time. Match colors to the role in the work, not seniority.

---

## Next steps (multi-column) <a id="steps"></a>

3-column ownership breakdown — what each person does over the next N days.

```html
<section class="section">
  <h2 class="section-title">Next steps — date range</h2>
  <div class="steps">
    <div class="step-col">
      <h3>Owner · role</h3>
      <ul>
        <li><strong>When — action verb</strong>What they're doing and why</li>
        <li><strong>When — action verb</strong>Next thing</li>
      </ul>
    </div>
    <!-- repeat 2-3 more columns -->
  </div>
</section>
```

**Tip:** put the date (or "Today") in the `<strong>` so it left-aligns visually. Body text wraps below.

---

## Parked grid (future workstreams) <a id="parked"></a>

2-column compact cards for things explicitly deferred. Includes optional inline transcript quote.

```html
<section class="section">
  <h2 class="section-title">Parked — future workstreams</h2>
  <div class="parked-grid">
    <div class="parked-card">
      <div class="parked-title">Item title</div>
      One or two sentences describing the parked item, why it's parked, what triggers reactivation.
      <div class="quote quote-transcript" style="margin-top: 10px; padding: 8px 12px; font-size: 11px;">
        <div class="quote-attrib">From the room — date (Speaker)</div>
        <p>"Source quote that captures why this item was raised."</p>
      </div>
      <span class="parked-meta">Owner · timeline</span>
    </div>
    <!-- repeat -->
  </div>
</section>
```

The transcript quote inside a parked card is opt-in — include when the source quote helps justify why it's parked, omit when the prose is enough.

---

## Footer <a id="footer"></a>

```html
<footer>
  Org legal entity · Confidentiality marker · Generated DD MMM YYYY
</footer>
```

Tiny uppercase footer. Update both the generated and (if relevant) the updated date when the doc evolves.

---

## Tying it all together

A fully-loaded doc reads top to bottom:

1. Header → reader knows the title, date, audience, headline in 5 seconds
2. Tracks / overview → reader knows the shape of the work
3. Closed items + open decisions → reader knows the state of play
4. Gaps → reader walks the substantive content
5. Side discussions → secondary decisions
6. Timeline → when things happen
7. Owners → who does what
8. Next steps → concrete this-week actions
9. Parked → what we explicitly deferred
10. Footer → marker

Skip sections that don't apply. Order can shift — a strategy memo might lead with "Open decisions" before "Tracks". The patterns are interchangeable building blocks; the document's narrative is what holds them together.
