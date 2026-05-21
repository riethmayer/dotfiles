# Level 1 — Big Picture EventStorming

This is the level you start at. It's a **discovery** workshop — the goal is to make the whole business process visible end-to-end, surface conflicts, blockers, goals, and find the most compelling problem. **Disagreements are OK at this level** — they're the signal, not the noise.

You're NOT yet trying to design code. Don't reach for aggregates, commands, policies, or read models. They'll come at the next level.

## What's on the wall

Only four kinds of sticky:

- **Orange — Domain Events** (past tense). The spine of the timeline.
- **Magenta — Hotspots.** Questions, frictions, conflicts, "wait, is that really how it works?". As valuable as the events.
- **Pink — External Systems.** Anything you don't own — Stripe, DHL, a sister team's API, a regulator.
- **Small yellow — People.** Roles, not names. "Shopper", "Warehouse Op", "Underwriter".

In `storm.json` terms: only `event` / `events`, `hotspot`, `system`, `actor` per column. Leave `command`, `policy`, `read_model` empty — the renderer will hide those lanes so the Big-Picture view stays uncluttered.

## How the conversation goes

1. **Chaotic exploration.** Ask the user to dump events. Past tense, no order required. Five or fifteen — doesn't matter, you'll cluster after.
   > "Let's start by listing what *happens* in this domain — anything notable, in the past tense. Doesn't have to be in order; doesn't have to be complete."
2. **Enforce the timeline.** Rearrange events left-to-right in causal order. Read the narrative back as a story:
   > "OK so the story so far is: a customer registers → views a product → adds to cart → starts checkout… Does that match how it actually flows? Anything missing between these steps?"
   This read-back is the cheapest way to find missing events and contradictions. *Don't skip it.*
3. **Pin the people and systems** to the events they touch. Who initiates? What third-party gets called?
4. **Capture hotspots constantly.** Every time the user says "I think", "usually", "it depends", "we used to" — that's a hotspot. Put it next to the relevant event.

## Brandolini's four success criteria

A Big-Picture storm is done when:

1. **Every path is completed** — the spine ends in a stable state (happy customer, refund issued, order rejected — not mid-flow).
2. **Color grammar is respected** end-to-end.
3. **Every stakeholder is reasonably happy** with their view of the process.
4. **Every hotspot has been addressed** — answered inline, or explicitly noted for follow-up.

If any of these fail, you're not done. The fifth rule ("aggregates should be coherent") only kicks in at Software Design level.

## Outcomes you're after

- A **validated business narrative** that reads cleanly end-to-end.
- A set of **explicit hotspots** that nobody can pretend don't exist.
- A first guess at **bounded-context boundaries** (where does Storefront end and Fulfillment begin?).
- An identified **most compelling problem** to attack with the next level.

If you've got those, you've earned the right to escalate to Level 2.

## When to stop and zoom

- The narrative reads cleanly → escalate to Process Modeling.
- One specific hotspot is becoming the conversation → narrow scope and start a focused Process Modeling pass on it.
- The user keeps trying to add commands/policies → push back gently: "let's stay at events first, we'll get to that in a moment."

## Common Big-Picture mistakes

- **Events in present tense or imperative** ("Place Order" instead of "Order Placed"). Always flip them.
- **UI screens as events** ("Cart Page Shown"). That's a consequence of an event, not an event.
- **Skipping failure paths.** Payment declined, address invalid, package lost — these are first-class events.
- **Storming the tech, not the business.** "Kafka Topic Published" is not a domain event. "Order Confirmed" is.
- **Premature design.** If the user starts arguing about aggregates or which microservice owns what, you've drifted into the wrong level. Pull back.

## Example

`assets/ecommerce-bp.storm.json` is a Big-Picture storm of an online shop — 18 events end-to-end, hotspots on the questions a real team would surface on the first day, no commands or aggregates. Render with `python scripts/build_storm_svg.py assets/ecommerce-bp.storm.json --out /tmp/bp.svg`.
