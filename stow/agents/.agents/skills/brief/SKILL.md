---
name: brief
description: >-
  Write a board-ready decision brief using structured interviewing. Produces a
  concise document with Situation, Stakes, Constraints, Key Question, Options,
  and Recommendation. Use when user says "write a brief", "brief this",
  "decision brief", "board brief", "prepare a brief", or needs to frame a
  decision for leadership.
---

# Brief

Produce a one-page decision brief by interviewing the user, then writing a tight document a board or leadership team can act on in under 5 minutes.

Template: [assets/brief-template.md](assets/brief-template.md)

## Process

### 1. Get the topic

Ask the user: **"What decision do you need the board to make?"**

If they give a topic rather than a question, reframe it as a question and confirm.

### 2. Interview — fill every section

Walk through each template section as a mini grill-me. Go one section at a time, resolve it, then move on. Do not skip ahead.

**Situation** — Ask for facts only. Push back on opinions or spin. Probe:
- What changed recently that makes this urgent?
- What are the current numbers?
- What has already been tried?

**Stakes** — Force asymmetry. Probe:
- What's the best-case outcome if we act?
- What happens if we do nothing for 6 months?
- Who else is affected beyond this team?

**Constraints** — Be exhaustive. Walk through each category (budget, timeline, team, technical, regulatory, personal). Hidden constraints derail deliberations — surface them now.

**Key Question** — Distill to one sentence. If the user gives multiple questions, push them to pick the one that, if answered, makes the others fall into place.

**Options** — Require at least 2, cap at 4. For each: what, cost, risk, unlocks. If the user only sees one path, ask "What would you do if that option disappeared?"

**Recommendation** — Ask the user what they'd pick and why. Capture in 2-3 sentences.

### 3. If a question can be answered from context, answer it yourself

Before asking the user, check whether the answer is in the codebase, existing docs, or conversation history. Only ask when information genuinely requires the user's judgment or knowledge.

### 4. Write the brief

Output the completed brief using the template. Replace all `<placeholder>` tags with real content. The title should be the key question reframed as a concise statement.

### 5. Save the brief

**Default location:** `briefs/<YYYY-MM-DD>-<slug>/README.md` in the project root. Generate the slug from the brief title (lowercase, hyphens, no special chars).

If the user provided a Notion page as input, replace that page's content with the brief (don't create a new subpage). If working in an Obsidian vault, save there instead.

Otherwise, confirm the default path before writing:

> Saving to `briefs/2026-03-24-attribution-tracking/README.md` — ok?

## Style Rules

- **No jargon** — write for a partner who hasn't been in the weeds
- **No hedge words** — "might", "could potentially", "it seems" — cut them
- **Concrete numbers** over vague qualifiers — "11% conversion" not "low conversion"
- **One page max** — if it's longer, cut. Brevity is respect for the reader's time.
