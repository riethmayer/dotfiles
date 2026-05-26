"""Generate the lifecycle-canvas SVG for /shape's details.html.

Reads a shape.json with the canvas content (user-story-map backbone +
event-storm timeline) and emits a self-contained <svg>...</svg> block to
stdout — paste directly into the page's canvas section.

Usage:
  python scripts/build_canvas_svg.py path/to/shape.json
  python scripts/build_canvas_svg.py path/to/shape.json --out canvas.svg

Input shape.json (canvas portion only — see references/canvas_schema.md):
{
  "story_map": {
    "backbone": ["Browse", "Install", "Use", "Author", "Share", "Govern"],
    "tasks": {
      "Browse":  ["Search public", "Search workspace", "See screenshots"],
      "Install": ["sync down", "Download zip", "Per-tool training"],
      ...
    },
    "slices": [
      {
        "title": "SLICE 1 · MVP — Browse + sync + use",
        "assignments": {
          "Browse":  [0, 1],
          "Install": [0, 1],
          "Use":     [0, 1]
        }
      },
      { "title": "SLICE 2 · v1 — Author + submit + bless", "assignments": { ... } },
      ...
    ]
  },
  "event_storm": {
    "actors": ["Author", "Eng Admin", "Member"],
    "timeline": [
      {"kind": "cmd",    "label": "Init"},
      {"kind": "event",  "label": "Skill Drafted"},
      {"kind": "policy", "label": "Push to Members"},
      {"kind": "read",   "label": "Hooks · PII · Evals"},
      ...
    ]
  }
}

Geometry is deterministic. The model does NOT pick coordinates — it just
declares activities, tasks, slices, and the event-storm sequence.

Brandolini palette (event storm):
  orange  = domain event  (past tense)
  blue    = command       (imperative)
  yellow  = actor
  purple  = policy / process
  green   = read model / aggregate state
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

# --- palette -----------------------------------------------------------
CLR_EVENT = "#ffb86b"
CLR_CMD = "#a5d8ff"
CLR_ACTOR = "#ffec99"
CLR_POLICY = "#d0bfff"
CLR_READ = "#b2f2bb"
CLR_BACKBONE = "#ffe8a3"
CLR_BG = "#FBF7EE"
CLR_SLICE_BG = ["#fff7e6", "#e8f5e9", "#e3f2fd", "#fff0f0", "#f0eaff", "#e6fffa"]

KIND_TO_COLOR = {
    "cmd": CLR_CMD,
    "event": CLR_EVENT,
    "actor": CLR_ACTOR,
    "policy": CLR_POLICY,
    "read": CLR_READ,
}
KIND_ROW = {"cmd": 0, "event": 1, "policy": 2, "read": 3}

FONT = "'Untitled Sans', Inter, -apple-system, BlinkMacSystemFont, sans-serif"
HEADING = "#7a1a1a"
DIM = "#6b6560"
INK = "#1e1e1e"

# --- helpers -----------------------------------------------------------

def _rect(x, y, w, h, fill, stroke=INK, sw=2, rx=8, opacity=1.0, dash=""):
    dash_attr = f' stroke-dasharray="{dash}"' if dash else ""
    op = f' opacity="{opacity}"' if opacity != 1.0 else ""
    return (
        f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" ry="{rx}" '
        f'fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{op}{dash_attr} />'
    )


def _text(x, y, s, size=14, anchor="middle", weight="600", color=INK):
    return (
        f'<text x="{x}" y="{y}" font-size="{size}" font-family="{FONT}" '
        f'font-weight="{weight}" text-anchor="{anchor}" fill="{color}">{s}</text>'
    )


def _sticky(x, y, w, h, color, label, size=14):
    return _rect(x, y, w, h, color, sw=2, rx=6) + _text(x + w / 2, y + h / 2 + size / 3, label, size=size)


# --- builders ----------------------------------------------------------

def _build_story_map(sm: dict, origin_x: float, origin_y: float, col_w: int = 270) -> tuple[list[str], float, float]:
    """Returns (svg_elements, occupied_width, occupied_height)."""
    out: list[str] = []
    backbone: list[str] = sm["backbone"]
    tasks: dict[str, list[str]] = sm.get("tasks", {})
    slices: list[dict] = sm.get("slices", [])

    col_gap = 16
    backbone_h = 56
    row_h = 56
    task_gap = 8
    slice_pad = 18
    slice_gap = 14

    out.append(_text(origin_x, origin_y + 24, "USER STORY MAP", size=24, anchor="start", weight="700", color=HEADING))
    out.append(_text(origin_x, origin_y + 46, "Columns = activities · Horizontal swimlanes = release slices", size=13, anchor="start", weight="500", color=DIM))

    backbone_y = origin_y + 60
    tasks_top = backbone_y + backbone_h + 28
    map_w = len(backbone) * (col_w + col_gap)

    # Compute per-slice max tasks for height
    slice_heights: list[float] = []
    for slc in slices:
        max_in_cell = 1
        for _, idxs in slc.get("assignments", {}).items():
            if len(idxs) > max_in_cell:
                max_in_cell = len(idxs)
        slice_heights.append(slice_pad * 2 + max_in_cell * row_h + (max_in_cell - 1) * task_gap)

    # Slice swimlanes
    slice_ys: list[float] = []
    cursor = tasks_top
    for i, h in enumerate(slice_heights):
        slice_ys.append(cursor)
        bg = CLR_SLICE_BG[i % len(CLR_SLICE_BG)]
        out.append(_rect(origin_x - 10, cursor, map_w + 20, h, bg, stroke="#7a3b09", sw=1, rx=10, opacity=0.45, dash="6 5"))
        out.append(_text(origin_x + 4, cursor + 18, slices[i].get("title", f"SLICE {i + 1}"), size=12, anchor="start", weight="700", color="#7a3b09"))
        cursor += h + slice_gap

    # Backbone
    for i, activity in enumerate(backbone):
        x = origin_x + i * (col_w + col_gap)
        out.append(_sticky(x, backbone_y, col_w, backbone_h, CLR_BACKBONE, activity, size=20))

    # Tasks per (activity, slice) cell
    for sl_idx, slc in enumerate(slices):
        cell_top = slice_ys[sl_idx] + slice_pad + 14
        for activity, idxs in slc.get("assignments", {}).items():
            if activity not in backbone:
                continue
            bb_x = origin_x + backbone.index(activity) * (col_w + col_gap)
            for k, ti in enumerate(idxs):
                label = tasks.get(activity, [])[ti] if ti < len(tasks.get(activity, [])) else f"task#{ti}"
                ty = cell_top + k * (row_h + task_gap)
                out.append(_sticky(bb_x, ty, col_w, row_h, CLR_CMD, label, size=14))

    total_h = (cursor - origin_y) if slices else (backbone_y + backbone_h - origin_y)
    return out, map_w, total_h


def _build_event_storm(es: dict, origin_x: float, origin_y: float) -> tuple[list[str], float, float]:
    out: list[str] = []
    actors: list[str] = es.get("actors", [])
    timeline: list[dict] = es.get("timeline", [])

    sticky_w = 130
    sticky_h = 60
    col_x_gap = 130  # so columns nudge into each other; the y-row separation makes it readable
    row_h = 78
    stack_gap = 4  # vertical gap between stacked stickies within the same row

    out.append(_text(origin_x, origin_y + 24, "EVENT STORM (Brandolini)", size=24, anchor="start", weight="700", color=HEADING))
    out.append(_text(origin_x, origin_y + 46, "Left → right is time · orange=event · blue=command · purple=policy · green=read model · yellow=actor", size=13, anchor="start", weight="500", color=DIM))

    # Group timeline into columns. Items with parallel=true stack into the
    # previous column instead of advancing the x cursor — same logical time,
    # stacked vertically within their row band.
    columns: list[list[dict]] = []
    for item in timeline:
        if item.get("parallel") and columns:
            columns[-1].append(item)
        else:
            columns.append([item])

    # Actor lane: spread evenly across timeline width
    actor_y = origin_y + 70
    actor_count = max(1, len(actors))
    actor_w = 160
    out.append(_text(origin_x, actor_y - 10, "ACTORS", size=12, anchor="start", weight="800", color=HEADING))

    timeline_x_start = origin_x + 40
    timeline_total_w = len(columns) * col_x_gap + sticky_w
    for i, actor in enumerate(actors):
        # Spread actors across the timeline width
        x = timeline_x_start + (timeline_total_w - actor_w) * (i / max(1, actor_count - 1)) if actor_count > 1 else timeline_x_start
        out.append(_sticky(x, actor_y + 4, actor_w, 56, CLR_ACTOR, actor, size=18))

    # Timeline header
    timeline_top = actor_y + 110
    out.append(_text(origin_x, timeline_top - 14, "TIMELINE (commands → events → policies → read models)", size=12, anchor="start", weight="800", color=HEADING))

    # Render columns; within each column, stack same-row stickies vertically
    max_stack_per_row: dict[int, int] = {}
    for col_idx, col_items in enumerate(columns):
        x = timeline_x_start + col_idx * col_x_gap
        row_offsets: dict[int, int] = {}
        for item in col_items:
            kind = item.get("kind", "event")
            label = item.get("label", "")
            color = KIND_TO_COLOR.get(kind, CLR_EVENT)
            row = KIND_ROW.get(kind, 1)
            offset = row_offsets.get(row, 0)
            y = timeline_top + row * row_h + offset * (sticky_h + stack_gap)
            row_offsets[row] = offset + 1
            max_stack_per_row[row] = max(max_stack_per_row.get(row, 1), row_offsets[row])
            size = 12 if len(label) > 14 else 13
            out.append(_sticky(x, y, sticky_w, sticky_h, color, label, size=size))

    # Account for the deepest stack in each row when sizing the canvas
    extra_h = sum(max(0, max_stack_per_row.get(r, 1) - 1) * (sticky_h + stack_gap) for r in range(4))
    total_h = timeline_top + 4 * row_h - origin_y + 20 + extra_h
    total_w = max(actor_w + (actor_count - 1) * 40, timeline_total_w) + 60
    return out, total_w, total_h


def _build_legend(x: float, y: float) -> list[str]:
    out: list[str] = []
    legend = [
        (CLR_EVENT, "Domain event"),
        (CLR_CMD, "Command"),
        (CLR_ACTOR, "Actor"),
        (CLR_POLICY, "Policy"),
        (CLR_READ, "Read model"),
    ]
    out.append(_rect(x - 12, y - 8, 340, len(legend) * 28 + 28, "#ffffff", stroke="#2D1A16", sw=1, rx=8, opacity=0.9))
    out.append(_text(x + 4, y + 12, "LEGEND", size=11, anchor="start", weight="800", color=HEADING))
    for i, (color, label) in enumerate(legend):
        ly = y + 30 + i * 26
        out.append(_rect(x + 4, ly, 26, 18, color, stroke=INK, sw=1, rx=4))
        out.append(_text(x + 40, ly + 14, label, size=12, anchor="start", weight="600"))
    return out


def build_svg(shape: dict) -> str:
    origin_x = 60
    cursor_y = 60
    elements: list[str] = []

    # Story map
    map_els: list[str] = []
    map_w = 0.0
    map_h = 0.0
    if "story_map" in shape:
        map_els, map_w, map_h = _build_story_map(shape["story_map"], origin_x, cursor_y)
        cursor_y += map_h + 50

    # Divider hint between the two boards
    if "story_map" in shape and "event_storm" in shape:
        elements.append(_text(origin_x, cursor_y - 20, "↓  Domain events emitted as users walk the story map", size=14, anchor="start", weight="700", color=HEADING))

    # Event storm
    storm_els: list[str] = []
    storm_w = 0.0
    storm_h = 0.0
    if "event_storm" in shape:
        storm_els, storm_w, storm_h = _build_event_storm(shape["event_storm"], origin_x, cursor_y)
        cursor_y += storm_h

    # Total canvas dimensions
    page_w = max(map_w + 2 * origin_x, storm_w + 2 * origin_x, 1700)
    page_h = cursor_y + 40

    out: list[str] = []
    out.append(f'<svg viewBox="0 0 {int(page_w)} {int(page_h)}" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="USM and event storm canvas">')
    out.append(f'<rect width="100%" height="100%" fill="{CLR_BG}" rx="0" />')
    out.extend(map_els)
    out.extend(elements)
    out.extend(storm_els)
    # Legend top-right
    out.extend(_build_legend(page_w - 360, 64))
    out.append("</svg>")
    return "\n".join(out)


def main() -> int:
    p = argparse.ArgumentParser(description="Build the /shape lifecycle-canvas SVG")
    p.add_argument("shape_json", type=Path, help="Path to shape.json")
    p.add_argument("--out", type=Path, default=None, help="Write SVG to this file instead of stdout")
    args = p.parse_args()

    if not args.shape_json.exists():
        print(f"shape.json not found: {args.shape_json}", file=sys.stderr)
        return 2

    shape = json.loads(args.shape_json.read_text())
    canvas = shape.get("canvas", shape)  # accept either {"canvas": {...}} or the canvas object directly
    svg = build_svg(canvas)

    if args.out:
        args.out.write_text(svg)
        print(f"wrote {args.out} ({len(svg) / 1024:.1f} KiB)", file=sys.stderr)
    else:
        sys.stdout.write(svg)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
