"""Convert a storm.json into a .tldr file you can open at tldraw.com.

The static SVG renderer ships a tombstone of the storm. The real artefact
is a whiteboard: pan, zoom, drag, draw your own arrows, branch the happy
path. tldraw is free, web-based, and supports import via "File ▸ Open" of
a .tldr file. This script emits one.

Usage:
  python scripts/build_tldraw.py storm.json --out storm.tldr

Input schema (extends the existing storyline schema):

  {
    "title":     "Online Shop — Big Picture",
    "subtitle":  "...",
    "happy_path": [                       // events on the top line
      {"kind": "event", "label": "Customer Registered"},
      ...
    ],
    "branches": [                          // alternative paths below
      {
        "from": 1,                         // index into happy_path
        "label": "What if email verification fails?",
        "beats": [
          {"kind": "event",   "label": "Verification Failed"},
          {"kind": "hotspot", "label": "Auto-retry vs manual?"}
        ]
      }
    ]
  }

Backwards-compatible with the existing `storyline: [...]` flat schema —
in which case everything goes on one row.

Layout philosophy: place stickies on a coarse grid as a starting point;
the user is expected to drag them in tldraw. We are seeding the canvas,
not freezing the layout.
"""

from __future__ import annotations

import argparse
import json
import secrets
import string
import sys
from pathlib import Path

# ---- tldraw colour palette (the set tldraw v3 accepts on note shapes) ----
# Brandolini's grammar maps onto these as best we can.
KIND_TO_TLDRAW_COLOR = {
    "event":   "orange",
    "command": "blue",
    "actor":   "yellow",
    "policy":  "violet",
    "read":    "light-green",
    "system":  "grey",           # neutral grey — keeps it distinct from hotspot
    "hotspot": "violet",         # rendered as a diamond outline; see hotspot_record
    "aggregate": "light-violet",
}

# Human-readable label for the legend.
KIND_LABEL = {
    "event":   "Event",
    "command": "Command",
    "actor":   "Actor",
    "policy":  "Policy",
    "read":    "Read Model",
    "system":  "External System",
    "hotspot": "Hotspot",
}

# Order in which legend stickies stack from top to bottom.
LEGEND_ORDER = ["event", "command", "actor", "policy", "read", "system", "hotspot"]

# Decorative prefixes added to the sticky label.
ACTOR_GLYPH = "🧍"          # stick-figure person — rendered large alongside the sticky
OUTCOME_GLYPH = {
    "happy": "🤣",          # rolling laugh — Brandolini-style happy customer
    "sad":   "😭",          # loudly crying — sad customer
}

# Note shapes in tldraw are 200×200 by default — tldraw stretches the sticky
# vertically to fit text but the base width is fixed.
NOTE_W = 200
NOTE_H = 200

# Horizontal stride between stickies on a path. Slightly wider than NOTE_W
# so there's a visible gap and the user has room to drag arrows in tldraw.
STRIDE_X = 260

# Vertical stride between the happy path and each branch lane.
LANE_Y = 320

# Top-left origin for the happy path
ORIGIN_X = 200
ORIGIN_Y = 200


def make_id(prefix: str) -> str:
    """tldraw record id — typeName:nanoid-style suffix."""
    alphabet = string.ascii_letters + string.digits + "_-"
    suffix = "".join(secrets.choice(alphabet) for _ in range(21))
    return f"{prefix}:{suffix}"


def rich_text(s: str) -> dict:
    """tldraw v3.10+ uses tiptap rich text on note shapes."""
    return {
        "type": "doc",
        "content": [
            {
                "type": "paragraph",
                "content": [{"type": "text", "text": s}] if s else [],
            }
        ],
    }


def note_record(beat: dict, x: float, y: float, page_id: str, index: str) -> dict:
    """Build a tldraw note shape record for one beat.

    Actor and outcome glyphs are NOT embedded in the label here — they're
    rendered as separate text shapes (see `glyph_record`) so the emoji can
    be much larger than the label text without scaling the whole sticky.
    """
    kind = beat.get("kind", "event")
    label = str(beat.get("label", "?"))
    color = KIND_TO_TLDRAW_COLOR.get(kind, "yellow")

    outcome = beat.get("outcome")
    if outcome == "happy":
        color = "light-green"
    elif outcome == "sad":
        color = "red"

    # When a glyph will be drawn in the upper portion of the sticky
    # (actor / outcome), push the label to the bottom so they don't overlap.
    has_glyph = kind == "actor" or outcome in OUTCOME_GLYPH
    vertical_align = "end" if has_glyph else "middle"

    return {
        "id": make_id("shape"),
        "typeName": "shape",
        "type": "note",
        "x": x,
        "y": y,
        "rotation": 0.0,
        "isLocked": False,
        "opacity": 1.0,
        "parentId": page_id,
        "index": index,
        "props": {
            "color": color,
            "labelColor": "black",
            "size": "m",
            "font": "draw",
            "align": "middle",
            "verticalAlign": vertical_align,
            "growY": 0,
            "url": "",
            "fontSizeAdjustment": 0,
            "scale": 1,
            "richText": rich_text(label),
        },
        "meta": {"kind": kind},
    }


def glyph_record(glyph: str, sticky_x: float, sticky_y: float,
                 page_id: str, index: str) -> dict | None:
    """A large standalone emoji rendered INSIDE the upper portion of an
    actor/outcome sticky. The sticky's label is pushed to the bottom via
    verticalAlign="end" so the two don't collide."""
    if not glyph:
        return None
    return {
        "id": make_id("shape"),
        "typeName": "shape",
        "type": "text",
        # Centred horizontally on the sticky, sitting in the upper third.
        "x": sticky_x + NOTE_W / 2 - 40,
        "y": sticky_y + 10,
        "rotation": 0.0,
        "isLocked": False,
        "opacity": 1.0,
        "parentId": page_id,
        "index": index,
        "props": {
            "color": "black",
            "size": "xl",
            "w": 100,
            "font": "draw",
            "textAlign": "middle",
            "autoSize": True,
            "scale": 2.2,
            "richText": rich_text(glyph),
        },
        "meta": {"role": "beat-glyph"},
    }


def text_record(label: str, x: float, y: float, page_id: str, index: str,
                color: str = "black", size: str = "l") -> dict:
    """A free-floating text label (e.g. the title or branch caption)."""
    return {
        "id": make_id("shape"),
        "typeName": "shape",
        "type": "text",
        "x": x,
        "y": y,
        "rotation": 0.0,
        "isLocked": False,
        "opacity": 1.0,
        "parentId": page_id,
        "index": index,
        "props": {
            "color": color,
            "size": size,
            "w": 600,
            "font": "draw",
            "textAlign": "start",
            "autoSize": True,
            "scale": 1,
            "richText": rich_text(label),
        },
        "meta": {},
    }


def fractional_index(i: int) -> str:
    """tldraw uses fractional indices (e.g. "a1", "a2", "a3") for z-order."""
    return f"a{i + 1}"


def _emit_beat(beat: dict, x: float, y: float, page_id: str,
               next_index_fn, records: list[dict]) -> None:
    """Append the records needed to render a single beat to `records`.

    Most beats become one note shape. Hotspots become a diamond geo shape.
    Actors get a 🧍 emoji over the note; outcome events get a 🤣 / 😭 over
    the note.
    """
    kind = beat.get("kind", "event")
    if kind == "hotspot":
        records.append(hotspot_record(beat, x, y, page_id, next_index_fn()))
        return
    records.append(note_record(beat, x, y, page_id, next_index_fn()))
    glyph = _beat_glyph(beat)
    if glyph:
        records.append(glyph_record(glyph, x, y, page_id, next_index_fn()))


def _beat_glyph(beat: dict) -> str | None:
    """Return the glyph to render alongside a beat, if any."""
    if beat.get("kind") == "actor":
        return ACTOR_GLYPH
    outcome = beat.get("outcome")
    return OUTCOME_GLYPH.get(outcome)


def hotspot_record(beat: dict, x: float, y: float, page_id: str, index: str) -> dict:
    """Hotspots render as purple-outlined diamonds, not notes. The shape
    visually distinguishes them as 'open question / problem' rather than
    just another sticky."""
    label = str(beat.get("label", "?"))
    return {
        "id": make_id("shape"),
        "typeName": "shape",
        "type": "geo",
        "x": x,
        "y": y,
        "rotation": 0.0,
        "isLocked": False,
        "opacity": 1.0,
        "parentId": page_id,
        "index": index,
        "props": {
            "geo": "diamond",
            "w": NOTE_W,
            "h": NOTE_H,
            "color": "violet",
            "labelColor": "black",
            "fill": "solid",
            "dash": "draw",
            "size": "m",
            "font": "draw",
            "align": "middle",
            "verticalAlign": "middle",
            "growY": 0,
            "url": "",
            "scale": 1,
            "richText": rich_text(label),
        },
        "meta": {"role": "hotspot"},
    }


def aggregate_band_record(name: str, x: float, y: float, w: float, h: float,
                          page_id: str, index: str) -> dict:
    """A translucent yellow `geo` rectangle behind a run of same-aggregate beats."""
    return {
        "id": make_id("shape"),
        "typeName": "shape",
        "type": "geo",
        "x": x,
        "y": y,
        "rotation": 0.0,
        "isLocked": False,
        "opacity": 0.4,
        "parentId": page_id,
        "index": index,
        "props": {
            "geo": "rectangle",
            "w": w,
            "h": h,
            "color": "yellow",
            "labelColor": "yellow",
            "fill": "semi",
            "dash": "draw",
            "size": "s",
            "font": "draw",
            "align": "start",
            "verticalAlign": "start",
            "growY": 0,
            "url": "",
            "scale": 1,
            "richText": rich_text(name),
        },
        "meta": {"role": "aggregate-band"},
    }


def collect_aggregate_ranges(beats: list[dict]) -> list[tuple[str, int, int]]:
    """Find runs of adjacent beats sharing the same `aggregate` value.

    Returns [(name, start_index, end_index_inclusive), ...].
    """
    out = []
    i = 0
    while i < len(beats):
        agg = beats[i].get("aggregate")
        if not agg:
            i += 1
            continue
        j = i
        while j + 1 < len(beats) and beats[j + 1].get("aggregate") == agg:
            j += 1
        out.append((agg, i, j))
        i = j + 1
    return out


def legend_records(page_id: str, next_index_fn) -> list[dict]:
    """A column of reference stickies (one per Brandolini kind) at the very
    left of the canvas, so the user can decode the color grammar at a
    glance. Cards are full-size so emoji + label fit comfortably."""
    out: list[dict] = []
    legend_x = ORIGIN_X - 600  # sit well to the left of the happy path
    legend_y_top = ORIGIN_Y - 60
    legend_stride_y = 240      # full-height cards need taller spacing
    # Heading
    out.append({
        "id": make_id("shape"),
        "typeName": "shape",
        "type": "text",
        "x": legend_x,
        "y": legend_y_top - 50,
        "rotation": 0.0,
        "isLocked": False,
        "opacity": 1.0,
        "parentId": page_id,
        "index": next_index_fn(),
        "props": {
            "color": "black",
            "size": "m",
            "w": 220,
            "font": "draw",
            "textAlign": "start",
            "autoSize": True,
            "scale": 1,
            "richText": rich_text("Legend"),
        },
        "meta": {},
    })
    for i, kind in enumerate(LEGEND_ORDER):
        y = legend_y_top + i * legend_stride_y
        label = KIND_LABEL[kind]
        # Render the legend entry through the same beat pipeline so the
        # canvas-side appearance (diamond for hotspot, big emoji for actor,
        # etc.) is reflected in the legend automatically.
        legend_beat = {"kind": kind, "label": label}
        _emit_beat(legend_beat, legend_x, y, page_id, next_index_fn, out)
    # Two outcome stickies at the bottom — happy + sad. Use the same beat
    # pipeline so the big emoji + bottom-aligned label render correctly.
    for i, outcome in enumerate(["happy", "sad"]):
        y = legend_y_top + (len(LEGEND_ORDER) + i) * legend_stride_y
        legend_beat = {
            "kind": "event",
            "outcome": outcome,
            "label": f"{outcome.title()} outcome",
        }
        _emit_beat(legend_beat, legend_x, y, page_id, next_index_fn, out)
    return out


def build_tldr(storm: dict) -> dict:
    document_id = "document:document"
    page_id = make_id("page")

    records: list[dict] = []

    # Document and page (the structural parents).
    records.append({
        "id": document_id,
        "typeName": "document",
        "gridSize": 10,
        "name": storm.get("title", "Event Storm"),
        "meta": {},
    })
    records.append({
        "id": page_id,
        "typeName": "page",
        "name": storm.get("title", "Event Storm"),
        "index": "a1",
        "meta": {},
    })

    z = 0
    def next_index() -> str:
        nonlocal z
        s = fractional_index(z)
        z += 1
        return s

    # Title + subtitle as canvas text in the top-left.
    title = storm.get("title", "")
    subtitle = storm.get("subtitle", "")
    if title:
        records.append(text_record(title, ORIGIN_X - 40, ORIGIN_Y - 180,
                                   page_id, next_index(), size="xl"))
    if subtitle:
        records.append(text_record(subtitle, ORIGIN_X - 40, ORIGIN_Y - 120,
                                   page_id, next_index(), color="grey", size="m"))

    # Resolve the happy path. Accept either the new branched schema
    # (`happy_path` + `branches`) or the older flat `storyline`.
    happy_path = storm.get("happy_path") or storm.get("storyline") or []
    branches = storm.get("branches", [])

    # Legend column on the left (drawn before the storyline so it stays put).
    records.extend(legend_records(page_id, next_index))

    # Aggregate bands first (so they render *behind* the stickies).
    agg_ranges = collect_aggregate_ranges(happy_path)
    for name, start, end in agg_ranges:
        # Aggregate band wraps the run from start to end inclusive, with a
        # bit of padding so the stickies sit visually inside it.
        pad = 20
        x = ORIGIN_X + start * STRIDE_X - pad
        y = ORIGIN_Y - pad - 4
        w = (end - start) * STRIDE_X + NOTE_W + pad * 2
        h = NOTE_H + pad * 2 + 8
        records.append(aggregate_band_record(name, x, y, w, h, page_id, next_index()))

    # Happy path along the top line.
    happy_xs: list[float] = []
    for i, beat in enumerate(happy_path):
        x = ORIGIN_X + i * STRIDE_X
        y = ORIGIN_Y
        happy_xs.append(x)
        _emit_beat(beat, x, y, page_id, next_index, records)

    # Each branch hangs off a happy-path beat, going down and to the right.
    for bi, branch in enumerate(branches):
        from_idx = branch.get("from", 0)
        from_x = happy_xs[from_idx] if 0 <= from_idx < len(happy_xs) else ORIGIN_X
        lane_y = ORIGIN_Y + LANE_Y * (bi + 1)
        # Optional branch caption above the first sticky in the lane
        if branch.get("label"):
            records.append(text_record(
                branch["label"],
                from_x,
                lane_y - 60,
                page_id,
                next_index(),
                color="red",
                size="m",
            ))
        for i, beat in enumerate(branch.get("beats", [])):
            x = from_x + i * STRIDE_X
            y = lane_y
            _emit_beat(beat, x, y, page_id, next_index, records)

    return {
        "tldrawFileFormatVersion": 1,
        "schema": {"schemaVersion": 2, "sequences": {}},
        "records": records,
    }


def main(argv=None) -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("input", help="Path to storm.json")
    ap.add_argument("--out", help="Output .tldr path (default: stdout)")
    args = ap.parse_args(argv)

    storm = json.loads(Path(args.input).read_text())
    tldr = build_tldr(storm)
    payload = json.dumps(tldr, indent=2)

    if args.out:
        Path(args.out).write_text(payload)
        print(f"wrote {args.out}", file=sys.stderr)
    else:
        sys.stdout.write(payload)


if __name__ == "__main__":
    main()
