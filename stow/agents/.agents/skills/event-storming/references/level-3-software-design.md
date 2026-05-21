# Level 3 — Software-Design EventStorming

You've done Big Picture (discovery) and Process Modeling (validated narrative). Now you're designing **code**. The conversation pattern flips: where BP was about surfacing disagreement, here you're searching for **agreement** — and consensus is hard.

Brandolini's framing: *"Ambiguity does not compile."* At this level, fuzzy is no longer a feature.

## What's on the wall — adds the Aggregate

Same colors as Process Modeling, plus:

- **Yellow (large) — Aggregates.** A noun with a lifecycle. The state machine that owns a tight run of consecutive events. In the SVG, an aggregate is drawn as a translucent yellow band wrapping the events that belong to it, with the aggregate's name labeled above.

In `storm.json` terms: now populate `aggregates: [{name, events}]` and optionally `bounded_contexts: [{name, events}]`. Indices must wrap **contiguous** event runs.

The fifth game-rule Brandolini adds at this level: **Aggregates should be coherent.**

## Investigating aggregates

Three rules of thumb:

1. **State machine logic.** An aggregate is the place where commands hit state and emit events. If you can't draw the state diagram, you don't have an aggregate.
2. **Focus on behaviour, not data.** Don't name the aggregate after the data it holds (`OrderRecord`) — name it after the behaviour it enforces (`Order`, `Shipment`, `Return`).
3. **Postpone naming.** First decide where the boundary is, then argue about what to call it. Don't fall in love with your first intuition.

## The closed-loop grammar at SD level

The Process-Modeling loop expands to make the aggregate explicit:

```
       (Actor)
          │
   looks-at ▼
       (Read Model)
          │
   decides ▼
       [Command]  ──→  ((Aggregate))  ──→  ⟨Event⟩  ──→  [Policy]  →  [Command] → …
                       enforces invariant
```

The aggregate's job is to **refuse illegal commands** and emit the events that result from legal ones. If you don't have an invariant to defend, you don't need an aggregate boundary there — the events can belong to whatever neighbour aggregate makes the most sense.

## Symmetries on the timeline

A useful pattern-spotting exercise: scan the timeline left-to-right looking for **shape symmetries**. The same micro-shape — `Policy → Command → Aggregate → Event → ...` — repeated at different points usually means:

- The same **aggregate** is showing up in more than one place.
- The same **policy** governs more than one situation.
- A **bounded context** has duplicate logic that could be unified, or *should* deliberately stay separate.

When you spot a symmetry, ask: "are these the same thing, or do they just look the same?"

## Pivotal events and bounded contexts

After the aggregates are pinned, scan for **pivotal events** — points where the story meaningfully changes shape (`Order Placed` splits "the customer is still shopping" from "the warehouse owns it"). Pivotal events are natural seams for **bounded contexts**.

A bounded context is looser than an aggregate: several aggregates with shared vocabulary, all belonging to one sub-domain (`Storefront`, `Checkout & Payment`, `Fulfillment`, `After-Sales`). In the SVG, drawn as a dashed band that wraps a wider stretch of the timeline behind everything else.

## How the conversation goes

1. **Look for state machines.** Walk the timeline asking "what's the noun whose lifecycle changes here?" Group consecutive events around the same noun.
2. **Argue boundaries before names.** "Is this still the Order, or is it the Shipment now?" Mark the dividing point.
3. **Spot pivotal events.** "If something blows up after this point, do we roll back or compensate?"
4. **Draw bounded-context bands** around aggregates that belong together.
5. **Address every hotspot** that the aggregate boundaries make worse or better. Some BP-level hotspots dissolve when you pick the right aggregate; some new ones appear ("who owns the consistency between Payment and Order?").

## What you're after at this level

- **Aggregates** with clear invariants.
- **Policies** with explicit triggers and named aggregates they touch.
- **Read models** with named owners.
- **IDs** — the entity IDs that tie everything together (orderId, customerId, paymentId). These rarely make it onto sticky notes but they matter when you start writing code.
- **Bounded contexts** that survive a hostile read by the architect.

## Common Software-Design mistakes

- **CRUD-shaped aggregates.** "Order" with `create / read / update / delete` is just a database. Look for behaviour.
- **Aggregate per entity.** Not every noun is an aggregate. Most data is a value object that lives inside an aggregate.
- **Bounded contexts the same shape as the org chart.** Real bounded contexts are about *language*, not about who reports to whom. Sometimes they align with teams; often they don't.
- **Designing the database, not the model.** The aggregate is the model. The database schema comes after.
- **Losing the business voice.** At SD level, engineers can dominate. Keep the domain expert in the room — they're the only check against "elegant but wrong".

## Strategies for getting unstuck

When the room can't agree on aggregate boundaries, Brandolini recommends:

- **Swarm:** everybody on the same problem. Fast, but easy to get stuck.
- **Mob:** one person drives, everyone else gives feedback. Good for politically sensitive boundaries.
- **Split & Merge:** small groups model separately, then reconcile. Good for big designs.

In a chat conversation: when the user is stuck on a boundary, offer two or three alternatives explicitly — name them, sketch the consequences, let them pick.

## Example

`assets/ecommerce-sd.storm.json` is a Software-Design storm — the full Process-Modeling spine, plus four aggregates (Cart, Order, Shipment, Return) and four bounded contexts (Storefront, Checkout & Payment, Fulfillment, After-Sales). Render with `python scripts/build_storm_svg.py assets/ecommerce-sd.storm.json --out /tmp/sd.svg`.
