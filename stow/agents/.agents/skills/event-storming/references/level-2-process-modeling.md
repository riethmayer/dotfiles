# Level 2 — Process Modeling EventStorming

You've done a Big-Picture pass — the spine reads cleanly, the hotspots are out in the open. Now the goal shifts: take **one slice** of the business and validate the narrative deeply, finding the *value*, the *personas*, the *individual goals*, the *policies*. You're scoping down (one process, not the whole company) and zooming in (more colors on the wall).

The Big-Picture rule was "disagreements are OK". Here it shifts subtly: you're still surfacing tension, but you're starting to **negotiate the agreement** that the next level (Software Design) will compile.

## What's on the wall — same colors as BP plus three new ones

In addition to the BP set (events, hotspots, systems, people), add:

- **Blue — Commands.** Imperative verb. "Place Order", "Submit Address". Sits above the event it causes.
- **Lilac — Policies.** Reactive logic: "whenever X then Y". Sits below the event it reacts to. *This is the special guest of the grammar.*
- **Green — Read Models.** What the actor is *looking at* when they decide to issue the command. A screen, a report, a list.

In `storm.json` terms: now populate `command`, `policy`, `read_model` on each column. The renderer un-hides those lanes.

## The closed-loop "grammar in action"

Once you've added all the colors, the basic loop is:

```
       (Actor)
          │
   looks-at ▼
       (Read Model)
          │
   decides ▼
       [Command]  ──→  ⟨Event⟩
                          │
                  activates ▼
                      [Policy]
                          │
                   triggers ▼
                      [Command] → …
```

Events update read models. Read models inform actors. Actors issue commands. Commands cause events. Events trigger policies. Policies issue new commands. The loop keeps closing — and that's how you discover the next step you didn't know was there.

## How the conversation goes

For each event on the spine, walk through:

1. **Actor + command.** "Who caused this, and what did they do?" → small-yellow actor + blue command above the event.
2. **Read model.** "What did they look at before deciding?" → green sticky below. If there's nothing to look at, the actor is acting on memory or reflex — *that's worth noting*.
3. **Policy.** "Does anything mechanically happen because of this event, without a human deciding?" → lilac sticky. "On X → do Y" form. The policy is where you'll find logic the engineers have buried and the business has forgotten.

## Concurrent events stack

When one command or policy emits several events at the same moment, they stack vertically in the same column (`events: [...]` in JSON):

- **Command fan-out:** `Add to Cart` emits both `Item Added to Cart` and `Cart Items Frozen`.
- **Policy fan-out:** `On Order Placed → reserve + send confirmation` emits both `Inventory Reserved` and `Order Confirmation Sent`.

Don't conflate this with *alternative outcomes* — `Payment Authorized` vs `Payment Declined` are different moments, each its own column.

## The policies spectrum

Brandolini distinguishes three flavors of policy — all the same lilac sticky, but understanding which one you're looking at matters:

- **Implicit:** Nobody wrote it down. Everyone is supposed to follow it, but nobody can quote it. This is where the lies live.
- **Explicit:** Written somewhere. Documented. Still relies on humans.
- **Automated:** Code. Listeners, sagas, process managers. The policy is in the system.

When you find an implicit policy, that's a hotspot. Make it explicit on the wall.

## What you're after at this level

- **Value Proposition** — for each event, who gets value? Money is one currency; time, stress, joy, reputation are others. Look for events that destroy value and ask why.
- **Personas + individual goals** — what does each actor *want* out of this process?
- **Explicit policies** — every "whenever X then Y" is now on a sticky, not in someone's head.
- **A cleaner narrative** than you had at BP, with no implicit logic.

## Common Process-Modeling mistakes

- **Adding events backwards.** When you discover a new event mid-process-modeling, slot it into the spine. Don't just hang it off a policy.
- **Stale events.** If a policy points to an event that doesn't exist on the spine, either add the event or kill the policy.
- **Granularity drift.** If commands and events keep getting smaller and smaller (recursive policies inside aggregates), you've drifted into Level 3 — pull back or formally escalate.
- **Skipping the read model.** "What did they look at?" sounds obvious but it's where you discover that the screen the user actually needs doesn't exist yet.

## When to stop and zoom

- The narrative is coherent and the policies are explicit → escalate to Software Design.
- One actor's flow has become its own conversation → split off a focused storm for them.
- The business has answered all the open questions → you have requirements, ship to Linear, no need for Level 3 unless you're also designing the code.

## Example

`assets/ecommerce-process.storm.json` is a Process-Modeling storm — same 20-column spine as the BP version, but with commands, policies, and read models populated. Render with `python scripts/build_storm_svg.py assets/ecommerce-process.storm.json --out /tmp/proc.svg`.
