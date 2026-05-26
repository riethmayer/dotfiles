# Canvas data — `shape.json`

The lifecycle canvas at the heart of `details.html` is built from a small JSON declaration. Coordinates are deterministic — you describe the *meaning* of the canvas, not where boxes sit.

Run the builder to emit the SVG:

```bash
python scripts/build_canvas_svg.py shape.json --out /tmp/canvas.svg
# or pipe to stdout if you want to inline it directly
python scripts/build_canvas_svg.py shape.json
```

Paste the `<svg>...</svg>` block into the marked canvas section of `details.html` (see [example_details.html](./example_details.html) for the placement).

## Schema

```jsonc
{
  "slug": "kebab-case-id",            // used for folder name
  "title": "Human title",              // shown in HTML headers
  "date": "YYYY-MM-DD",                // creation date (don't bump on edits)

  "canvas": {
    "story_map": {
      "backbone": ["Activity 1", "Activity 2", ...],   // ordered top row
      "tasks": {
        "Activity 1": ["task A", "task B", "task C"],  // tasks under each activity
        "Activity 2": [...],
        ...
      },
      "slices": [
        {
          "title": "SLICE 1 · MVP — short subtitle",
          "assignments": {
            "Activity 1": [0, 1],     // indices into tasks["Activity 1"]
            "Activity 2": [0]
          }
        },
        { "title": "SLICE 2 · v1 — ...", "assignments": { ... } },
        { "title": "SLICE 3 · v2 — ...", "assignments": { ... } }
      ]
    },

    "event_storm": {
      "actors": ["Author", "Eng Admin", "Member"],     // spread across timeline
      "timeline": [
        { "kind": "cmd",    "label": "Init" },         // imperative, present tense
        { "kind": "event",  "label": "Skill Drafted" },// past tense
        { "kind": "event",  "label": "Index Updated", "parallel": true }, // stacks below the previous sticky (same logical time)
        { "kind": "policy", "label": "Open PR" },      // automatic/process step
        { "kind": "read",   "label": "Hooks · PII" }   // read model / view
      ]
    }
  }
}
```

## Brandolini palette (do not invent new colors)

| `kind`   | Means                | Convention                                   | Color    |
|----------|----------------------|----------------------------------------------|----------|
| `cmd`    | Command              | Imperative verb (an actor decides to do X)   | Blue     |
| `event`  | Domain event         | Past tense (the system records that X happened) | Orange  |
| `actor`  | Actor / user         | Noun, the kind of person doing the work      | Yellow   |
| `policy` | Policy / process     | Automatic reaction ("when X happens, do Y")  | Purple   |
| `read`   | Read model / view    | What's visible / queryable about state       | Green    |

If you find yourself wanting another color, you probably want a different `kind` — not a new one. Brandolini's economy of stickies is the point.

## Authoring tips

- **Backbone activities are verbs the user does, not features.** "Browse · Install · Use · Author · Share · Govern", not "Search · Auth · API · CLI."
- **Tasks under an activity are the concrete steps the user takes through it.** Three is usually enough.
- **Slices are release cuts**, not roadmap quarters. Slice 1 must be a complete vertical path through the backbone — sparse but end-to-end. Slice 2 / 3 fill in the boxes a row at a time.
- **Event-storm timeline is causally ordered left → right.** A command produces an event; a policy reacts to an event and triggers the next command. Read models exist to make a decision.
- **Parallel events stack vertically.** Set `"parallel": true` on a timeline item to keep it in the previous column (same x), stacking below within its row band. Use when one command emits multiple events at the same logical time (e.g. a migration script that seeds users + groups + members in one go). The first item of a parallel group has no `parallel` flag — subsequent siblings carry it.
- **Aim for ~20–30 stickies on the storm.** More gets cluttered at SVG scale; less and you probably haven't thought about reversibility / failure paths.

## Re-generation

The canvas SVG is large (~20 KB) and inlined into `details.html`. To update the canvas without hand-editing the HTML:

1. Edit `shape.json`.
2. Re-run the builder, capturing the output to a temp file.
3. Replace the `<svg>...</svg>` block in `details.html` between the `<!-- canvas:start -->` and `<!-- canvas:end -->` markers (see the example).

Keep `shape.json` next to the HTML — it's the source of truth for the canvas and the input `/linear` reads when it carves issues from the slices and events.
