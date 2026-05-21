# EventStorming grammar — cross-cutting reference

The whole point of the grammar is to keep the conversation between domain experts and engineers cheap: same color = same kind of thing, same physical position = same place in time. Stick to it at every level.

## The sticky-note types

| Sticky | Element | Voice / form | First appears at |
| --- | --- | --- | --- |
| Orange | Domain event | past tense, business-relevant | Level 1 |
| Violet diamond | Hotspot | question, conflict, friction | Level 1 |
| Grey | External system | third-party / black box | Level 1 |
| Yellow + 🧍 | Actor / persona | role, not name | Level 1 |
| Blue | Command | imperative verb | Level 2 |
| Violet | Policy | "whenever X then Y" | Level 2 |
| Green | Read model | a screen or data the actor looks at | Level 2 |
| Green + 🤣 / Red + 😭 | Outcome | tagged event ending a path | Level 1 |
| Yellow band | Aggregate | noun with a lifecycle, wraps a contiguous run of events | Level 3 |

In Brandolini's original paper grammar, hotspots are *magenta stickies*. The `.tldr` renderer uses a **violet diamond** instead so they stand out as "open question" rather than just another sticky on the wall — tldraw's solid colors on rectangles read similarly to events otherwise. External systems are *grey* here (rather than Brandolini's pink) for the same reason: tldraw's "light-red" was too close to outcome red, so grey buys cleaner contrast.

## The arrow of time

Time flows left-to-right. Orange domain events form the **spine**. Everything else is positioned vertically *relative to its triggering event*:

- **Actors** sit at the top — they're who-issued-what.
- **Commands** sit just above the event they cause.
- **Read models** sit below commands — what the actor was looking at.
- **Policies** sit below the event they react to.
- **External systems** sit below policies — they emit or receive events.
- **Hotspots** sit at the bottom — out of the way but never thrown away.

The renderer follows this lane order top-to-bottom and hides lanes that have no content (so a Big-Picture storm shows only the lanes actually in use).

## Past tense, always

Domain events must be in the past — "Order Placed", not "Place Order" (that's a command), not "Placing Order" (that's a UI state). The past tense is what forces the conversation onto what *actually happened in the business* rather than what the software does. If a sticky won't fit "<thing> was <past-participle>", it's not a domain event.

## Hotspots — don't sweep them away

A workshop that ends without hotspots is a workshop where people were too polite to disagree. Every "wait, is that really how it works?", "what about X edge case?", "we used to do it differently" goes on a magenta sticky next to the relevant event. They're the unfinished business — and they're as valuable as the diagram itself.

This is true at every level, not just Big Picture. At Process Modeling, hotspots flag implicit policies. At Software Design, they flag aggregate boundary disputes.

## What you're NOT modeling

- **UI screens, microservice boundaries, database tables** — they're consequences, not the model.
- **Implementation details inside an aggregate** — go down one more level only if the *business* cares.
- **Happy path only** — when something can fail (payment declined, package lost), that's an event too. Add it.
- **Code-shaped events** — "Kafka Topic Published", "POST /orders called". Not domain events. "Order Confirmed" is.

## Fuzzy by design

At Big Picture and Process Modeling, **imprecise definitions are deliberate**. They let everyone in the room (and the chat) contribute regardless of background. The fuzziness triggers conversation — somebody clarifies "wait, that's not exactly what I meant" and the precision falls out of the dialog.

At Software Design level the rule flips: *ambiguity does not compile*. Force the precision then, not before.
