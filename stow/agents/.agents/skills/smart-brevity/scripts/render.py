#!/usr/bin/env python3
"""Render Smart Brevity rewrite to a styled HTML diff and open it.

Input JSON shape (read from --input or stdin):

    {
      "title": "Q4 update rewrite",
      "format": "memo",                       # email | memo | slack | long-doc | onboarding | presentation
      "assembled": "...",                     # optional; if omitted, built from segments
      "segments": [
        {
          "id": "1.1",                        # flat "1" or nested "1.1"
          "section": "Q4 Results",            # optional, used to insert section headers
          "before": "verbatim original paragraph",
          "after": "rewritten paragraph (markdown ok: **bold**, bullets, headings)",
          "rules_violated": [3, 7, 12],
          "rationale": "Led with the number; cut three warm-up sentences."
        }
      ]
    }

Output: /tmp/smart-brevity-<timestamp>.html (or --output <path>), opened in browser.

Usage:
  python3 render.py --input segments.json
  cat segments.json | python3 render.py
  python3 render.py --input segments.json --output /tmp/my-rewrite.html --no-open
"""

from __future__ import annotations

import argparse
import json
import pathlib
import re
import sys
import time
import webbrowser
from html import escape

RULE_NAMES = {
    1:  "Lead with answer",
    2:  "One idea/sentence",
    3:  "Cut filler",
    4:  "Why it matters",
    5:  "Scannable structure",
    6:  "Value first",
    7:  "Simple words",
    8:  "Short paragraphs",
    9:  "Strong verbs",
    10: "Informative headlines",
    11: "Bold selectively",
    12: "No warm-ups",
    13: "Conversational",
    14: "Compress",
    15: "Clarity > completeness",
}


def word_count(text: str) -> int:
    text = re.sub(r"[*_`#>\-]+", " ", text or "")
    return len(re.findall(r"\w+", text))


def md_to_html(text: str) -> str:
    """Minimal markdown → HTML for rewrite blocks. Handles **bold**, *italic*,
    `code`, lists (- / *), headings (### → h4), and the literal "Why it matters:"
    callout pattern. Paragraphs are split on blank lines.
    """
    if not text:
        return ""
    text = text.replace("\r\n", "\n")

    lines = text.split("\n")
    out: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i].rstrip()

        # Heading
        m = re.match(r"^(#{1,6})\s+(.*)$", line)
        if m:
            level = min(len(m.group(1)) + 1, 6)  # h1 in source → h2 in fragment
            out.append(f"<h{level}>{_inline(m.group(2))}</h{level}>")
            i += 1
            continue

        # Bulleted list
        if re.match(r"^\s*[-*]\s+", line):
            items = []
            while i < len(lines) and re.match(r"^\s*[-*]\s+", lines[i]):
                items.append(re.sub(r"^\s*[-*]\s+", "", lines[i]).rstrip())
                i += 1
            out.append("<ul>" + "".join(f"<li>{_inline(it)}</li>" for it in items) + "</ul>")
            continue

        # Numbered list
        if re.match(r"^\s*\d+[.)]\s+", line):
            items = []
            while i < len(lines) and re.match(r"^\s*\d+[.)]\s+", lines[i]):
                items.append(re.sub(r"^\s*\d+[.)]\s+", "", lines[i]).rstrip())
                i += 1
            out.append("<ol>" + "".join(f"<li>{_inline(it)}</li>" for it in items) + "</ol>")
            continue

        # Blank line
        if not line.strip():
            i += 1
            continue

        # Paragraph (gather contiguous non-blank, non-list lines)
        para: list[str] = []
        while i < len(lines) and lines[i].strip() and not re.match(r"^\s*([-*]|\d+[.)])\s+|^#{1,6}\s", lines[i]):
            para.append(lines[i].rstrip())
            i += 1
        joined = " ".join(para)
        out.append(f"<p>{_inline(joined)}</p>")

    return "\n".join(out)


def _inline(text: str) -> str:
    text = escape(text)
    # Bold **x** before italic *x* so bold wins
    text = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"(?<![\*])\*([^*\n]+)\*(?![\*])", r"<em>\1</em>", text)
    text = re.sub(r"`([^`]+)`", r"<code>\1</code>", text)
    return text


def assemble_plain(segments: list[dict], field: str = "after") -> str:
    """Concatenate a per-segment field ('before' or 'after') into one document.
    Section titles are inserted as `## headings` so the full-doc view keeps the
    same shape as the assembled rewrite.
    """
    parts: list[str] = []
    current_section = None
    for seg in segments:
        section = seg.get("section")
        if section and section != current_section:
            parts.append(f"## {section}")
            current_section = section
        text = (seg.get(field) or "").strip()
        if text:
            parts.append(text)
    return "\n\n".join(parts)


def assemble_html(segments: list[dict], field: str = "after") -> str:
    """Render the assembled rewrite (or source) as HTML for the top panel."""
    return md_to_html(assemble_plain(segments, field=field))


def render_word_delta(before: int, after: int) -> str:
    if before == 0:
        return f'<span class="word-delta">{after}w</span>'
    diff = after - before
    pct = round(100 * diff / before)
    sign_class = "down" if diff < 0 else ("up" if diff > 0 else "")
    arrow = "−" if diff < 0 else ("+" if diff > 0 else "·")
    return (
        f'<span class="word-delta">{before}w → {after}w '
        f'<span class="{sign_class}">{arrow}{abs(pct)}%</span></span>'
    )


def render_block(seg: dict) -> str:
    sid = seg.get("id", "?")
    safe_id = "block-" + re.sub(r"[^\w.-]+", "-", str(sid))
    before = seg.get("before", "") or ""
    after = seg.get("after", "") or ""
    rules = seg.get("rules_violated", []) or []
    rationale = seg.get("rationale", "") or ""
    bw = seg.get("before_words", word_count(before))
    aw = seg.get("after_words", word_count(after))

    rule_tags = "".join(
        f'<span class="rule-tag" data-rule="{n}" '
        f'title="Rule {n}: {escape(RULE_NAMES.get(n, "?"))} — click to see why">'
        f"R{n} {escape(RULE_NAMES.get(n, '?'))}</span>"
        for n in rules
    )

    return f"""
<div class="block" id="{safe_id}">
  <div class="block-head">
    <span class="block-id" onclick="copyId(this, '{escape(str(sid))}')" title="Click to copy [{escape(str(sid))}]">[{escape(str(sid))}]</span>
    {render_word_delta(bw, aw)}
    <div class="rule-tags">{rule_tags}</div>
  </div>
  <div class="block-body">
    <div class="side before">
      <div class="side-label">Before</div>
      <div class="side-content">{escape(before)}</div>
    </div>
    <div class="side after">
      <div class="side-label">After</div>
      <button class="copy-btn" onclick="copyAfter(this, '{escape(str(sid))}')">Copy</button>
      <div class="side-content">{md_to_html(after)}</div>
    </div>
  </div>
  {f'<div class="rationale"><strong>Why:</strong>{escape(rationale)}</div>' if rationale.strip() else ''}
</div>
"""


def render_blocks(segments: list[dict]) -> str:
    parts: list[str] = []
    last_section: str | None = None
    for seg in segments:
        section = seg.get("section")
        if section and section != last_section:
            parts.append(f'<h2 class="section">{escape(section)}</h2>')
            last_section = section
        parts.append(render_block(seg))
    return "\n".join(parts)


def render_page(data: dict) -> str:
    template_path = pathlib.Path(__file__).parent.parent / "assets" / "template.html"
    template = template_path.read_text(encoding="utf-8")

    title = data.get("title", "Smart Brevity rewrite")
    fmt = (data.get("format") or "text").lower()
    segments = data.get("segments", []) or []

    # Word counts
    for seg in segments:
        seg.setdefault("before_words", word_count(seg.get("before", "")))
        seg.setdefault("after_words", word_count(seg.get("after", "")))
    total_before = sum(seg["before_words"] for seg in segments)
    total_after = sum(seg["after_words"] for seg in segments)
    delta_pct = (
        f"{round(100 * (total_after - total_before) / total_before):+d}%"
        if total_before else "·"
    )

    assembled_plain = data.get("assembled") or assemble_plain(segments, field="after")
    assembled_html = md_to_html(assembled_plain)
    assembled_before_html = assemble_html(segments, field="before")

    plain_rewrites = {seg.get("id", str(i)): seg.get("after", "") for i, seg in enumerate(segments)}

    return (
        template
        .replace("${TITLE}", escape(title))
        .replace("${FORMAT}", escape(fmt))
        .replace("${BEFORE_WORDS}", str(total_before))
        .replace("${AFTER_WORDS}", str(total_after))
        .replace("${DELTA_PCT}", delta_pct)
        .replace("${BLOCK_COUNT}", str(len(segments)))
        .replace("${ASSEMBLED_HTML}", assembled_html)
        .replace("${ASSEMBLED_BEFORE_HTML}", assembled_before_html)
        .replace("${BLOCKS_HTML}", render_blocks(segments))
        .replace("${TIMESTAMP}", time.strftime("%Y-%m-%d %H:%M"))
        .replace("${PLAIN_REWRITES_JSON}", json.dumps(plain_rewrites))
        .replace("${ASSEMBLED_PLAIN_JSON}", json.dumps(assembled_plain))
    )


def main() -> int:
    ap = argparse.ArgumentParser(description="Render Smart Brevity HTML diff")
    ap.add_argument("--input", "-i", type=pathlib.Path, help="JSON input file (default: stdin)")
    ap.add_argument("--output", "-o", type=pathlib.Path, help="Output HTML path (default: /tmp/smart-brevity-<ts>.html)")
    ap.add_argument("--no-open", action="store_true", help="Don't auto-open in browser")
    args = ap.parse_args()

    raw = args.input.read_text(encoding="utf-8") if args.input else sys.stdin.read()
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"render.py: invalid JSON input — {e}", file=sys.stderr)
        return 1

    html = render_page(data)

    out = args.output or pathlib.Path(f"/tmp/smart-brevity-{int(time.time())}.html")
    out.write_text(html, encoding="utf-8")
    print(str(out))

    if not args.no_open:
        webbrowser.open(f"file://{out.resolve()}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
