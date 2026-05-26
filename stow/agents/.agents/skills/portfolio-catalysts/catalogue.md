---
version: 0.1.0
source_file: "202604 Catalyst Expertise-to-workshop collection_draft.xlsx"
imported_at: 2026-05-22
imported_by: jan
status: draft
maintainer: Portfolio Excellence (TBD nominated owner)
catalyst_count: 3
topic_count: 17
schema_version: 1
storage_layer: markdown
migration_target: BigQuery table (TBD)
note: |
  This is the v0 source of truth. The /deep-dive Block 7 reads this file
  directly. When Portfolio Excellence nominates a maintainer and the
  catalogue stabilises, migrate to a BigQuery table (or Notion DB with
  scheduled export) and update eb/ic/portfolio-catalysts/SKILL.md to
  read from the new layer.
---

# Earlybird Portfolio Excellence — Catalyst Catalogue

Workshop and 1-on-1 expertise that Earlybird Portfolio Excellence can offer founders. The catalogue is consumed by `/deep-dive` Block 7 to surface concrete catalysts during pre-call preparation, and by `/portfolio-catalysts` directly when an investor or portfolio company asks "what can we offer this founder right now?".

**What "catalyst" means here:** a named external expert with domain depth and a defined workshop or working-session format. The portco-fit columns in the original sheet are *guidance from the catalyst about which existing portcos might benefit* — useful as priors when matching against a new company, but not exclusive.

## Schema (per topic)

```yaml
catalyst: <name>
catalyst_role: <role + company>
catalyst_domain: <general topic — Growth / Sales / GTM / etc.>
topic: <specific topic>
stages: [<Pre-seed | Seed | Series A>, ...]
suggested_eb8_portcos: [<comma-separated names from the sheet>]
suggested_eb7_portcos: [<comma-separated names from the sheet>]
format: <workshop | working-session | 1-on-1 | small-group>
description: <multi-line text from the "Notes from Catalyst" column>
tags: [<derived keywords for matching>]
```

For matching against a deep-dive company, the deep-dive uses: `stages`, `catalyst_domain`, `tags`, and a semantic similarity check against `topic` + `description` to score relevance.

---

## Tilen

**Role:** Head of Content & Community, Synthesia
**Domain:** Growth / Marketing
**Format:** Workshops, working sessions
**Best for stages:** Pre-seed · Seed · Series A

### Topic — UGC Networks

- **Stages:** Pre-seed · Seed
- **Suggested EB8 portcos (catalyst's view):** Pillar, Sintra
- **Suggested EB7 portcos (catalyst's view):** —
- **Format:** Workshop / discussion
- **Tags:** ugc, creator-network, distribution, b2c, b2b, cpm, virality, paid-acquisition

> This is currently one of the cheapest CPM channels on the market, widely used by B2C / consumer apps in the US to drive virality and conversions, and now increasingly gaining traction in B2B due to its strong performance — e.g. a fast-growing dating app generated 294M views since Jan 2026 via a UGC creator network at a €0.28 CPM.

### Topic — Building a high-impact content engine (AI-first)

- **Stages:** Pre-seed · Seed · Series A
- **Suggested EB8 portcos:** Neuracore, Pillar, Sintra, SLNG, Briefcase, Bayshore, Porters
- **Suggested EB7 portcos:** —
- **Format:** Workshop + quick checklist
- **Tags:** content, ai-content, content-engine, growth, marketing-ops, tactical

> Workshop and a quick checklist built for companies with very tactical things they can do within the company to pick low-hanging fruit in AI content (there are many) and set up the team / company for success. Can share Tilen's personal examples and Synthesia examples.

### Topic — Going viral: repeatable frameworks for distribution

- **Stages:** Pre-seed · Seed · Series A
- **Suggested EB8 portcos:** SpAItial, SLNG, Briefcase
- **Suggested EB7 portcos:** —
- **Format:** Working session
- **Tags:** virality, distribution, founder-brand, attention, content-strategy

> From a brand perspective: how can a founder use their own brand profile to go viral / get attention. Tilen shares examples from his own work, Synthesia, and other companies.

### Topic — Community building from 0 → scale (Discord, etc.)

- **Stages:** Pre-seed · Seed · Series A
- **Suggested EB8 portcos:** Neuracore, SLNG, SpAItial, Briefcase
- **Suggested EB7 portcos:** —
- **Format:** Community design workshop
- **Tags:** community, discord, community-building, growth, retention

> Community being a popular buzzword with many different definitions, this workshop looks at the participants' companies and helps them define what a community could / should do for them and why. Output is a per-company community-design hypothesis.

### Topic — Scaling content production with AI tools

- **Stages:** Pre-seed · Seed · Series A
- **Suggested EB8 portcos:** SLNG, SpAItial, Briefcase
- **Suggested EB7 portcos:** —
- **Format:** Workshop
- **Tags:** content-ops, ai-tools, hiring, content-hire, scaling

> A closer look at content production with AI tools — and the important hiring question: who's a good content hire for the team at Pre-seed / Seed / Series A stage.

---

## Siobhan

**Role:** SMB / Mid-Market Sales Leader (ex DropBox, ex Figma)
**Domain:** Sales / GTM
**Format:** Workshops, working sessions, redesigns
**Best for stages:** Pre-seed · Seed · Series A

### Topic — Designing and optimising a scalable sales funnel (SMB → enterprise)

- **Stages:** Seed · Series A
- **Suggested EB8 portcos:** TopK, Briefcase, SLNG, SpAItial, Porters
- **Suggested EB7 portcos:** —
- **Format:** Workshop — bring your current funnel
- **Tags:** sales-funnel, smb, mid-market, enterprise, upmarket-motion, qualification, hand-offs

> Workshop on funnel architecture as a company moves upmarket — stage definitions, qualification gates, hand-offs between SMB / MM / ENT, and the signals that tell you you're ready to move. Founders bring their current funnel; the session redesigns one together.

### Topic — Forecasting & pipeline management (what "good" looks like)

- **Stages:** Seed · Series A
- **Suggested EB8 portcos:** SLNG, SpAItial, Porters, Briefcase
- **Suggested EB7 portcos:** EthonAI
- **Format:** Live working session — bring your real data
- **Tags:** forecasting, pipeline, sales-ops, cadence, deal-inspection, leading-indicators

> Founders bring whatever they use today for forecasting and pipeline review — spreadsheet, CRM view, back-of-envelope, anything. Siobhan works through each one live, pressure-tests what's working and what's breaking, and aligns on what "good" looks like at the founder's stage: weekly cadence, deal-inspection questions, forecast categories, and the leading indicators that predict the quarter.

### Topic — PLG → Sales: adding sales motion on top of product-led growth

- **Stages:** Seed · Series A
- **Suggested EB8 portcos:** SpAItial, Briefcase, SLNG
- **Suggested EB7 portcos:** —
- **Format:** Practical session
- **Tags:** plg, product-led, sales-overlay, self-serve, hand-offs, comp-structure

> For PLG companies layering on sales: which self-serve accounts to surface, how to avoid cannibalising PLG, hand-off design between product and sales, comp structure, and the early indicators the motion is working.

### Topic — Hiring first salesperson and the team that supports them

- **Stages:** Pre-seed · Seed · Series A
- **Suggested EB8 portcos:** Weve
- **Suggested EB7 portcos:** —
- **Format:** Working session
- **Tags:** first-hire, sales-hire, hunter-vs-farmer, sdr, sales-engineer, comp

> Building the first GTM team. The right profile for the first sales hire (hunter vs farmer, industry specialist vs generalist), where to source them, interview signals, realistic comp and ramp. Then sequences the supporting roles: when an SDR actually helps, when to hire a sales engineer / solutions architect / sales enablement.

### Topic — Landing first 10 customers

- **Stages:** Pre-seed · Seed
- **Suggested EB8 portcos:** Weve, Porters
- **Suggested EB7 portcos:** —
- **Format:** Working session — bring your target list
- **Tags:** first-customers, design-partner, pricing, contracts, roadmap-control

> How to source, pitch, and close the first 10 customers. Design-partner vs paying-customer trade-offs, what to charge (or not), contract shape, and how to keep your roadmap from being hijacked. Founders bring a target list; the session pressure-tests it together.

### Topic — Funnel diagnostics: where conversion breaks and how to fix it

- **Stages:** Seed · Series A
- **Suggested EB8 portcos:** —
- **Suggested EB7 portcos:** —
- **Format:** Live diagnostics
- **Tags:** funnel, conversion, bottlenecks, diagnostics, crm-export

> Founders bring their current funnel — CRM export, spreadsheet, whatever reflects reality. Siobhan diagnoses stage-by-stage conversion live, spots the true bottlenecks.

---

## Samantha

**Role:** Enterprise & large-ACV Client Sales Leader · President EMEA at Box (Sales, SDR, Marketing, CS)
**Domain:** GTM Leadership
**Format:** 1-on-1 deal reviews, small-group sessions, methodology workshops
**Best for stages:** Seed · Series A (enterprise-readiness focus)

### Topic — Priority deal review: 1-on-1

- **Stages:** Seed · Series A
- **Suggested EB8 portcos:** —
- **Suggested EB7 portcos:** —
- **Format:** 1-on-1 working session on a live opportunity
- **Tags:** deal-review, enterprise-sales, champion, economic-buyer, discovery, deal-rescue

> 1-on-1 working session on live opportunities. Samantha reviews a startup's deal, challenges assumptions on champion / economic buyer / business pain / discovery, and gives practical guidance on how to progress or rescue the deal.

### Topic — Priority deal review: small group of portcos

- **Stages:** Seed · Series A
- **Suggested EB8 portcos:** —
- **Suggested EB7 portcos:** —
- **Format:** Small-group working session
- **Tags:** deal-review, group-session, enterprise-sales, peer-learning

> Small-group working session on live opportunities. Founders bring deals; Samantha reviews each, challenges assumptions, and gives practical guidance on how to progress or rescue.

### Topic — Pipeline / forecast / operating cadence

- **Stages:** Seed · Series A
- **Suggested EB8 portcos:** —
- **Suggested EB7 portcos:** —
- **Format:** Small-group workshop
- **Tags:** pipeline, forecast, operating-cadence, dashboards, weekly-signals

> Small-group workshop on how founders should run pipeline reviews, forecast calls, and big-deal reviews — including what dashboards and signals to look at each week.

### Topic — Sales + marketing + SDR alignment

- **Stages:** Seed · Series A
- **Suggested EB8 portcos:** —
- **Suggested EB7 portcos:** —
- **Format:** Small-group session
- **Tags:** alignment, sales-marketing, sdr, messaging, outreach, lean-team

> Small-group session on how early-stage teams should align sales, marketing, and SDR efforts around messaging, content, outreach, and prioritisation in a lean team.

### Topic — Building channel partnerships in early markets

- **Stages:** Seed · Series A
- **Suggested EB8 portcos:** Bayshore, Porters, SLNG
- **Suggested EB7 portcos:** —
- **Format:** Short practical session
- **Tags:** channel, partnerships, dach, france, early-markets

> Short practical session on how early-stage teams can approach partnerships realistically, drawing on Samantha's experience in Germany and France to share what's working, what's hard, and how small teams can balance partner development with messaging, qualifying, and closing.

### Topic — Enterprise sales strategy

- **Stages:** Seed · Series A
- **Suggested EB8 portcos:** Porters, SLNG, Bayshore, SpAItial
- **Suggested EB7 portcos:** —
- **Format:** Practical session
- **Tags:** enterprise-sales, multi-stakeholder, economic-buyer, discovery, methodology, deal-review

> Practical session on how founders can sell into enterprise more effectively: how enterprise buying differs from SMB, how to navigate multiple stakeholders and economic buyers, how to improve discovery and qualification, and how to use a clear sales methodology and deal-review framework to avoid losing winnable deals.

---

## Portfolio reference — companies named in this catalogue

### EB8 (current portfolio)

Bayshore · Briefcase · Neuracore · Pillar · Porters · Sintra · SLNG · SpAItial · TopK · Weve

(The full EB8 active-company list is in `~/code/eagleeye/...` — `EB 8 Portcos` tab of the source xlsx. The names above are only those the three catalysts named in their fit suggestions.)

### EB7 (previous fund)

EthonAI

(Full EB7 active-company list also in the source xlsx. The above is only those named.)

---

## Source

`202604 Catalyst Expertise-to-workshop collection_draft.xlsx` (imported 2026-05-22). The original spreadsheet has columns the Portfolio Excellence team filled in: catalyst, general topic, specific topic, suitable stages, EB8 candidates, EB7 candidates, catalyst notes. This file mirrors that data with light structuring + tags derived for matching.

**Future maintenance:** when Portfolio Excellence nominates a maintainer, this file should be updated either:
- Directly in the skills repo (PR workflow), with `imported_at` bumped on each refresh
- OR migrated to a BigQuery table / Notion DB with scheduled export to this file
The matching logic in `eb/ic/portfolio-catalysts/SKILL.md` reads this file's structure; if the layer changes, update the SKILL.md.
