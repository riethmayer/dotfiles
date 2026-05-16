---
name: smart-brevity
description: Force clear, fast, scannable communication using the Smart Brevity writing system (Axios/Mike Allen). Rewrites the user's text — emails, memos, Slack messages, long docs, onboarding pages, presentation copy — into front-loaded, jargon-free, scanner-friendly prose with explicit "Why it matters" callouts. Produces a numbered before/after HTML diff (auto-opens in browser) so the user can reference specific blocks by ID (e.g. "redo 1.3") when iterating. Use this skill whenever the user says "/smart-brevity", "smart brevity", "make this tighter", "rewrite for clarity", "Axios-style", "front-load this", "trim this", "make this scannable", "tighten this memo/email/update/slack/doc", "edit for brevity", "shorten this", "this is too long", or pastes a block of text and asks for an edit pass. Also trigger proactively when the user shares writing for review and the prose is clearly verbose, jargon-heavy, or buries the lede — even if they don't name the framework.
---

# Smart Brevity

Rewrite the user's text so the most important idea lands in the first second, every sentence earns its place, and a scanner can extract the point in under ten.

This skill is an active editor, not a checker. The output is the rewrite — plus a numbered HTML diff that makes each edit referenceable for iteration.

## Workflow

**1. Get the source text.** Take it from the user's message, a file path, or clipboard. If ambiguous, ask once. Auto-detect the format (email, memo, Slack, long doc, onboarding/presentation copy) from cues — greeting → email, `#channel`/short → Slack, headers → memo or long doc. Ask only if genuinely ambiguous.

**2. Segment the text.** Split into addressable blocks:

- **Short text** (≤ ~500 words, no section headers): flat numbering — `[1]`, `[2]`, `[3]`, one block per paragraph.
- **Long text** (has headers, or > ~500 words): nested — `[1.1]`, `[1.2]` under Section 1, `[2.1]`, `[2.2]` under Section 2.

Keep blocks small enough that the user can iterate on one without re-editing its neighbours, but large enough that "before" and "after" are meaningful units of meaning — usually a paragraph. Never split mid-sentence.

**3. Rewrite each block** by applying the 15 rules in `references/rules.md`. The high-frequency violations:

1. **Lead with the answer.** First sentence stands alone with the conclusion.
2. **Make "Why it matters" explicit.** For any consequential point, add a `**Why it matters:**` line translating the fact into stakes.
3. **One idea per sentence.** Split stacked clauses.
4. **Cut filler.** "Actually", "really", "approximately", hedging, throat-clearing. If removing a word doesn't change meaning, remove it.
5. **Kill warm-up sentences.** "As you know…", "I wanted to reach out…", "Hope this finds you well…". Delete and start on substance.
6. **Plain words over jargon.** "Cut costs" beats "executed efficiency optimization initiatives".
7. **Bold the load-bearing 1–3 words per block.** Not whole sentences. Not nothing.
8. **Strong verbs over abstract nouns.** "The team launched" beats "the launch was executed".

Read `references/rules.md` for the full set with good/bad examples whenever you're unsure or need to justify a change.

**4. For each block, capture:**

- `before` — original paragraph text (verbatim)
- `after` — rewritten paragraph (Markdown allowed: `**bold**`, bullets, the `Why it matters:` callout)
- `rules_violated` — list of rule numbers `[3, 7, 12]` (from `references/rules.md`) explaining what was wrong
- `rationale` — one short line in plain English: "Led with the number, cut three throat-clearing sentences"
- `before_words` / `after_words` — word counts for the delta

**5. Render the HTML diff** using `scripts/render.py`:

```bash
python3 ~/.agents/skills/smart-brevity/scripts/render.py \
  --input /tmp/smart-brevity-segments.json \
  --title "Email rewrite" \
  --format email
```

Write the segment list as JSON to a temp path, then call the script. It produces `/tmp/smart-brevity-<timestamp>.html` and auto-opens it in the user's default browser. The HTML uses Earlybird brand styling and shows, per block:

- The block ID (`[1.3]`) — clickable, copies the ID to clipboard for chat reference
- Side-by-side before / after
- Rules violated as small tags (linking to the rule names)
- Word delta (`42 → 14 words, −67%`)
- Rationale line
- A copy button next to "after" that copies the rewritten text

The page also shows a **final assembled rewrite** at the top with a single "Copy all" button — that's the document the user actually ships.

**6. After rendering, tell the user concisely:** what file you wrote, that the browser is opening, and that they can reference blocks by ID (e.g. "redo 1.3, keep the bullet but soften the headline") to iterate.

## Iteration

The whole point of numbered blocks is iterative editing. When the user comes back with feedback like:

- `1.3 is too aggressive — soften`
- `keep 2.1 but drop the "Why it matters" line`
- `redo all of section 2 — make it more conversational`
- `merge 1.1 and 1.2`

regenerate only the affected blocks, keep all others verbatim, and re-render the HTML to the same file path (overwrite). The user reopens or refreshes. Don't ask permission to overwrite — they expect the file to update.

When the user says "ship it" / "looks good" / "give me the final", output the assembled rewrite as plain text (no markdown fences, per the user's preference for clipboard pastes) in the chat.

## Formats — what changes per format

The 15 rules are universal. A few format-specific defaults:

- **Email** — open with the ask or the news. Subject line first if you're rewriting that too. Keep "Why it matters" only if the recipient genuinely needs the stakes spelled out (skip for one-line replies).
- **Memo / update / briefing** — use headers, bullets, bolded headlines per section. "Why it matters" is non-optional for each top-level point.
- **Slack / chat** — strip even more aggressively. No headers. No "Why it matters" unless the thread is consequential. One short paragraph or 2–3 bullets, max.
- **Long doc** — section headers carry meaning independently (rule 10). Each section opens with its conclusion. Use the table of contents implied by your `[N.M]` numbering.
- **Onboarding / presentation copy** — every slide/section is one idea. Headlines convey the takeaway, not the topic. ("Revenue grew 38%" beats "Q4 Revenue".)

## What this skill should NOT do

- **Don't invent facts.** Rewriting can compress but must not add information the source doesn't contain. If the source is vague ("revenue grew"), the rewrite stays vague ("revenue grew") — not "revenue grew 38%".
- **Don't strip personality entirely.** Rule 11 (humanity and voice) matters. Smart Brevity isn't robotic — it's a tighter version of the human writing. If the source is warm or playful, the rewrite keeps that register, just lighter.
- **Don't add a critique or "score" of the original.** The user wants the rewrite, not a lecture. The rules-violated tags and rationale are enough.
- **Don't ask permission to start.** If the user pasted text and invoked the skill, start rewriting. Ask only if the input is ambiguous (e.g. "rewrite which part?").

## Files

- `references/rules.md` — the 15 rules with verification criteria and good/bad examples. Read when justifying edits or hitting an unfamiliar case.
- `assets/template.html` — HTML template used by the render script. Includes the Earlybird brand CSS, copy-to-clipboard JS, and the block layout.
- `scripts/render.py` — segment-JSON → HTML file → auto-open.
- `evals/evals.json` — test cases for the eval harness.
