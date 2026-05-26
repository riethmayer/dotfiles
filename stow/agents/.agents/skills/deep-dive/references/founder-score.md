# EagleEye founder-score — rubric + widget pattern

Source of truth: `~/code/eagleeye/data/transformation/seeds/harmonic_highlight_scores.csv` and `macros/classification.py`. Mirror this file if the canonical rubric drifts.

## Formula

```
score = LEAST(10, base_score + sum(tier1_matches × 2) + sum(tier2_matches × 1))
```

- **Base:** 3 points (every founder)
- **Cap:** 10

## Tier 1 (+2 each)

| Highlight                  | Matching signal                                |
|----------------------------|------------------------------------------------|
| Prior VC Backed Founder    | Founded a company that raised institutional VC |
| $M Club ($50M+)            | Involved in company exit / valuation milestones |
| YC Backed Founder          | Founded a Y Combinator company                 |
| Prior Exit                 | Meaningful exit (acquisition, IPO)              |

## Tier 2 (+1 each)

| Highlight                          | Matching signal                                                      |
|------------------------------------|----------------------------------------------------------------------|
| Seasoned Executive                  | C-level or VP at a notable company                                    |
| Prior VC Backed Executive           | Senior role at a VC-backed startup                                    |
| Elite Industry Experience           | World-class brands (LVMH, McKinsey, Goldman, etc.)                    |
| Top Company Alum                    | FAANG, Big Tech, top-tier corporates                                  |
| Seasoned Operator                   | Operational leadership (COO, Head of Ops, etc.)                       |
| Seasoned Founder                    | Serial founder (2+ ventures)                                          |
| Seasoned Adviser                    | Board member, advisor to multiple companies                           |
| Top University                      | Stanford, MIT, Oxbridge, INSEAD, IESE, HEC, etc.                       |
| Major Tech Company Experience       | Amazon, Google, Meta, Apple, Microsoft, etc.                          |
| Top AI Experience                   | Built or led AI/ML teams or products                                  |
| Deep Technical Background           | PhD in STEM, deep engineering/research career                          |
| Founder Turned Operator             | Transitioned from founder to executive/operator role                   |

## Routing thresholds

| Score | Routing                              |
|-------|--------------------------------------|
| < 7   | Excluded from pipeline               |
| 7     | Intern pool (round-robin)            |
| 8+    | Investor pool (by geography)         |

## Widget pattern — show the score, always with the breakdown

The widget appears at the founder's first mention in the brief (Block 3, expanded form). Subsequent mentions elsewhere use the compact pill `<span class="score-pill score-pill--founder">Score 7 ▾</span>`.

### Expanded widget HTML

```html
<div class="fscore">
  <div class="fscore-header">
    <span class="fscore-label">Founder score · {{founder_name}}</span>
    <span class="fscore-value">{{score}}<span class="denom">/10</span></span>
  </div>
  <div class="fscore-rows">
    <div class="fscore-row base">
      <span class="fscore-tier">B</span>
      <span class="fscore-name">Base</span>
      <span class="fscore-points">+3</span>
    </div>
    {{#each highlights}}
    <div class="fscore-row {{tier}}">
      <span class="fscore-tier">{{tier_label}}</span>
      <span class="fscore-name">{{name}} <em>· {{evidence}} {{cite}}</em></span>
      <span class="fscore-points">+{{points}}</span>
    </div>
    {{/each}}
  </div>
  <div class="fscore-meta">
    <strong>Source:</strong> {{sources}}.<br>
    <strong>Routing:</strong> {{routing_band}}.<br>
    <strong>Does this feel right?</strong> 👍 / 👎
  </div>
</div>
```

### Three properties of the widget that are non-negotiable

1. **Every highlight is footnoted.** "TU Munich" must carry `[L]`; "Roomex €4M round" must carry `[C]`. The reader can trace any contribution back to a source row in the warehouse.
2. **The base is always visible.** 3/10 isn't earned — it's the floor every founder gets. Making that floor explicit prevents the reading "this founder is a 3 (bad)" when in fact what we're saying is "we have no positive highlights on record".
3. **The routing implication is shown.** If a score crosses a routing threshold, call it out — that's the EU AI Act–relevant "consequence" of the score on the person.

## Inline pill — for body-text mentions

```html
<span class="score-pill score-pill--founder">Score 7 ▾</span>
```

The pill is the compact form used after the widget has already been rendered once in the brief. In a static HTML artifact the breakdown is in scope on the page; in an interactive medium the pill is clickable to scroll to the widget.

## The trust philosophy

> Surfacing the score everywhere builds trust over time **if and only if the reasoning travels with the number**. Without the breakdown, exposure creates familiarity (which produces anchoring bias). With the breakdown, exposure creates calibration (which is the actual goal).

Every Block 3 ends with `Does this feel right? 👍 / 👎` — a frictionless calibration event that feeds the eval suite. The score gets _measurably better_ over time because we surface it everywhere, not just more trusted.
