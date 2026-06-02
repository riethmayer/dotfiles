#!/usr/bin/env python3
"""Inject a direct link to a just-written debrief into today's daily HTML.

The daily brief renders a "Recently shipped" block, but only from the
recently-shipped.md index and only when the daily is (re)generated. A debrief
written *after* the daily was generated therefore never shows up in it. This
script closes that gap: it edits today's daily in place so the link is there
immediately, same-day, regardless of when the daily was built.

It owns its own marker-delimited block (`debriefs-today`) so it never depends on
how /daily happened to render its standup section:

  - First debrief of the day: create a `Debriefs filed today` <section> (the
    daily's sidebar auto-builds from <h2 class="section-title">, so it shows up
    in nav for free) and seed it with the link.
  - Later debriefs: prepend a <li> inside the existing markers (newest first).
  - Re-running the same debrief: no-op (deduped on href), since debrief
    overwrites the same HTML file rather than creating a new one.

Idempotent and non-fatal: if today's daily doesn't exist yet, it prints a note
and exits 0 (the index still feeds the daily whenever it's next generated).
"""

from __future__ import annotations

import argparse
import html
import sys
from pathlib import Path

START = "<!-- debriefs-today:start -->"
END = "<!-- debriefs-today:end -->"


def build_li(title: str, result: str, href: str, date: str) -> str:
    t = html.escape(title)
    r = html.escape(result)
    h = html.escape(href, quote=True)
    d = html.escape(date)
    # Mirrors the "Recently shipped" bullet shape: bold project, date, one-clause
    # result, then the debrief link (same-folder filename, so a bare href works).
    return (
        f'      <li><strong>{t}</strong> ({d}) - {r} '
        f'&middot; <a href="{h}">debrief</a></li>'
    )


def build_section(li: str) -> str:
    return (
        '<section class="section">\n'
        '  <h2 class="section-title">Debriefs filed today</h2>\n'
        '  <ul class="debriefs-today">\n'
        f'    {START}\n'
        f'{li}\n'
        f'    {END}\n'
        '  </ul>\n'
        '</section>\n'
    )


def insert_before_footer(doc: str, block: str) -> str | None:
    """Insert block just before the closing chrome. Returns None if no anchor."""
    for anchor in ("<footer", "</main>", "</body>"):
        idx = doc.rfind(anchor)
        if idx != -1:
            return doc[:idx] + block + "\n" + doc[idx:]
    return None


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--daily", required=True, help="path to today's daily HTML")
    ap.add_argument("--href", required=True, help="debrief link (same-folder filename is fine)")
    ap.add_argument("--title", required=True, help="project title")
    ap.add_argument("--result", required=True, help="one-clause result/outcome")
    ap.add_argument("--date", required=True, help="ISO date, e.g. 2026-06-02")
    args = ap.parse_args()

    daily = Path(args.daily)
    if not daily.is_file():
        print(f"no daily at {daily} yet - skipped direct link (index will feed it on next /daily)")
        return 0

    doc = daily.read_text(encoding="utf-8")

    # Dedupe: a re-run of the same debrief shouldn't add a second link.
    if f'href="{html.escape(args.href, quote=True)}"' in doc:
        print(f"daily already links {args.href} - no change")
        return 0

    li = build_li(args.title, args.result, args.href, args.date)

    if START in doc and END in doc:
        # Newest-first: drop the new <li> right after the start marker.
        doc = doc.replace(START, f"{START}\n{li}", 1)
        action = "appended to existing 'Debriefs filed today'"
    else:
        block = build_section(li)
        updated = insert_before_footer(doc, block)
        if updated is None:
            print(
                f"could not find an insertion anchor (<footer>/</main>/</body>) in {daily}; "
                "left it untouched",
                file=sys.stderr,
            )
            return 1
        doc = updated
        action = "created 'Debriefs filed today' section"

    tmp = daily.with_suffix(daily.suffix + ".tmp")
    tmp.write_text(doc, encoding="utf-8")
    tmp.replace(daily)
    print(f"{action} in {daily.name} -> {args.href}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
