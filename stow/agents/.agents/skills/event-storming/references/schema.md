# storm.json schema

The renderer (`scripts/build_tldraw.py`) reads a single JSON file and emits a `.tldr` you can open in tldraw. The model declares *what's in the storm*; geometry, layout, and tldraw-specific record IDs are handled deterministically.

## Top-level fields

```jsonc
{
  "title":      "Online Shop — Big-Picture Event Storm", // shown as canvas text
  "subtitle":   "Happy path along the top. ...",         // optional one-liner
  "happy_path": [Beat, Beat, ...],                       // required, the spine
  "branches":   [Branch, Branch, ...]                    // optional alt paths
}
```

## Beat — one sticky on the timeline

```jsonc
{
  "kind":    "event" | "command" | "actor" | "policy"
           | "read"  | "system"  | "hotspot",
  "label":   "Order Placed",        // REQUIRED, the sticky text
  "outcome": "happy" | "sad",       // OPTIONAL, only on events; turns the sticky
                                    // green/red and adds 🤣 / 😭 over the top
  "aggregate": "Order"              // OPTIONAL, Software-Design level only.
                                    // Contiguous beats sharing an aggregate
                                    // name get wrapped in a yellow band.
}
```

The renderer treats each beat as a single sticky:

- `event` → orange sticky, past-tense label. The default.
- `command` → blue sticky, imperative verb.
- `actor` → yellow sticky with a big 🧍 emoji over the top and the role name at the bottom.
- `policy` → violet sticky, "whenever X then Y" form.
- `read` → green sticky, the screen / data the actor consults.
- `system` → grey sticky, third-party / external system.
- `hotspot` → **violet diamond** (not a sticky shape) — visually distinct so questions stand out.

Tagging an event with `"outcome": "happy"` recolors it green and overlays a 🤣 emoji; `"outcome": "sad"` recolors it red with 😭. Use at the end of each path so Brandolini's first rule ("every path ends in a stable state") is enforceable at a glance.

## Branch — an alternative or failure path

```jsonc
{
  "from":  3,                                   // index into happy_path[]
                                                // the branch forks below this beat
  "label": "What if payment fails?",            // red caption above the branch
  "beats": [Beat, Beat, ...]                    // the same Beat shape as above
}
```

Branches stack downward — the first branch lane sits ~320px below the happy path, each subsequent branch ~320px below the previous. Each branch starts horizontally at the `from` beat's x position and extends right.

Brandolini's "Rush to the Goal" pattern: build the happy path first, mark every alternative with a hotspot, then come back and explore each branch. Branches typically:

1. Open with a hotspot (the open question that prompted the branch).
2. Walk through the alternative events.
3. End in an outcome — usually `outcome: "sad"` for failure modes, occasionally `"happy"` for happy detours (e.g. "what if the customer returns and we issue a refund?").

## Software-Design extras

When the level is Software Design, tag beats with `aggregate`:

```jsonc
{"kind": "event", "label": "Item Added to Cart",  "aggregate": "Cart"},
{"kind": "event", "label": "Cart Items Frozen",   "aggregate": "Cart"}
```

Adjacent beats with the same `aggregate` value get wrapped in a single translucent yellow band labeled with the aggregate's name. If you want to group non-adjacent beats, reorder the happy path so they're contiguous.

## Title text

The `title` and `subtitle` appear as plain text in the top-left of the canvas (in tldraw's hand-drawn font). Keep them short — they're a label, not a paragraph.

## Running the renderer

```bash
python scripts/build_tldraw.py path/to/storm.json --out path/to/storm.tldr
```

Then open the `.tldr` in real tldraw (see `SKILL.md` ▸ "Opening the .tldr file" for the three options).

## Tips for clean output

- Keep event labels under ~18 chars or they wrap to two lines (which is fine; three lines is cramped).
- Use **roles, not names** for actors ("Shopper", not "Jan").
- Past tense is enforced by convention, not by the script — *you* are the gatekeeper.
- A column may have only one kind; long fan-outs read clearly because every beat gets its own x position.
- Branches that share a `from` index render in separate lanes (one per branch). Order them so the most-likely-to-explore comes first.
