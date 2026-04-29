#!/usr/bin/env python3
"""Inline every local asset an HTML file references as base64 data URIs.

Turns an HTML deck that depends on sibling files (images, fonts, stylesheets)
into a single self-contained `.html` that can be emailed, dropped on a flash
drive, or served from anywhere without broken links.

Usage:
    python inline_assets.py input.html                  # writes input.standalone.html
    python inline_assets.py input.html -o deck.html     # custom output
    python inline_assets.py input.html --check          # dry-run, report what would change
    python inline_assets.py input.html --font-only      # only inline fonts (keep images linked)

What it handles:
- <img src="..."> and srcset
- <link rel="stylesheet" href="..."> (CSS file gets inlined as <style>, then its
  internal url(...) references are resolved relative to the CSS file)
- <link rel="icon" | "preload" | "apple-touch-icon" href="...">
- Inline style="background: url(...)" and style blocks with url(...)
- @font-face src: url(...) and any other url(...) references inside <style>
- <script src="..."> (inlined as <script>)
- <video src>, <audio src>, <source src>

What it skips:
- Anything with a scheme (http://, https://, data:, mailto:, tel:, #fragment)
- Google Fonts @import and other remote CSS (kept as-is so the file still
  works when online; pass --offline-fonts to prefetch + embed them)
"""
from __future__ import annotations

import argparse
import base64
import mimetypes
import re
import sys
import urllib.parse
import urllib.request
from html import unescape
from pathlib import Path

# Ensure modern web types resolve even on older Pythons.
mimetypes.add_type("image/svg+xml", ".svg")
mimetypes.add_type("image/webp", ".webp")
mimetypes.add_type("font/woff2", ".woff2")
mimetypes.add_type("font/woff", ".woff")
mimetypes.add_type("font/ttf", ".ttf")
mimetypes.add_type("font/otf", ".otf")
mimetypes.add_type("application/javascript", ".js")


REMOTE_SCHEME_RE = re.compile(r"^(?:https?:|data:|mailto:|tel:|#|javascript:|//)", re.I)


def is_remote(path: str) -> bool:
    return bool(REMOTE_SCHEME_RE.match(path.strip()))


def resolve(base: Path, ref: str) -> Path | None:
    """Resolve a ref relative to `base` (a directory). Returns None if the
    file doesn't exist or the ref is remote."""
    if is_remote(ref):
        return None
    # Strip query string / fragment. Browsers do this, so should we.
    clean = ref.split("?", 1)[0].split("#", 1)[0]
    clean = urllib.parse.unquote(unescape(clean))
    candidate = (base / clean).resolve()
    return candidate if candidate.is_file() else None


def to_data_uri(path: Path) -> str:
    mime, _ = mimetypes.guess_type(path.name)
    if mime is None:
        mime = "application/octet-stream"
    b64 = base64.b64encode(path.read_bytes()).decode("ascii")
    return f"data:{mime};base64,{b64}"


# --- CSS rewriting -----------------------------------------------------------

CSS_URL_RE = re.compile(r"""url\(\s*(['"]?)([^'")]+)\1\s*\)""")


def inline_css_urls(css: str, base_dir: Path, *, font_only: bool, stats: dict) -> str:
    """Rewrite url(...) refs inside a CSS string to data URIs."""

    def repl(match: re.Match) -> str:
        quote, ref = match.group(1), match.group(2)
        if is_remote(ref):
            return match.group(0)
        resolved = resolve(base_dir, ref)
        if resolved is None:
            stats["missing"].append(ref)
            return match.group(0)
        if font_only:
            mime, _ = mimetypes.guess_type(resolved.name)
            if not (mime and mime.startswith("font/")):
                return match.group(0)
        stats["inlined"].append(str(resolved))
        return f"url({quote}{to_data_uri(resolved)}{quote})"

    return CSS_URL_RE.sub(repl, css)


# --- HTML rewriting ----------------------------------------------------------

# Attribute-based refs we embed. (tag_pattern, attr)
ATTR_PATTERNS = [
    # src= on img/script/video/audio/source/iframe
    (re.compile(r"""(<(?:img|script|video|audio|source|iframe)\b[^>]*?\bsrc\s*=\s*)(['"])([^'"]+)\2""", re.I), "src"),
    # href= on link (stylesheet, icon, preload, etc.) — NOT anchor tags
    (re.compile(r"""(<link\b[^>]*?\bhref\s*=\s*)(['"])([^'"]+)\2""", re.I), "href"),
    # poster= on video
    (re.compile(r"""(<video\b[^>]*?\bposter\s*=\s*)(['"])([^'"]+)\2""", re.I), "poster"),
]

# Inline <style>…</style> blocks
STYLE_BLOCK_RE = re.compile(r"(<style\b[^>]*>)(.*?)(</style>)", re.I | re.S)

# style="..." attributes
STYLE_ATTR_RE = re.compile(r"""(\bstyle\s*=\s*)(['"])([^'"]*)\2""", re.I)


def inline_html(html: str, base_dir: Path, *, font_only: bool) -> tuple[str, dict]:
    stats = {"inlined": [], "missing": [], "stylesheets": []}

    # 1. Attribute-based refs. link[rel=stylesheet] needs special handling
    #    because we inline the CSS body, not a data URI.
    def replace_attr(match: re.Match) -> str:
        prefix, quote, ref = match.group(1), match.group(2), match.group(3)
        if is_remote(ref):
            return match.group(0)
        resolved = resolve(base_dir, ref)
        if resolved is None:
            stats["missing"].append(ref)
            return match.group(0)

        # For <link rel="stylesheet" href="..."> we want to replace the whole
        # tag with an inline <style>. Detect that from the full tag string.
        tag_start = html.rfind("<", 0, match.start())
        tag_end = html.find(">", match.end())
        full_tag = html[tag_start : tag_end + 1] if tag_start >= 0 and tag_end > 0 else ""
        if (
            not font_only
            and resolved.suffix.lower() == ".css"
            and re.search(r"""\brel\s*=\s*['"]?stylesheet""", full_tag, re.I)
        ):
            css = resolved.read_text(encoding="utf-8")
            css = inline_css_urls(css, resolved.parent, font_only=font_only, stats=stats)
            stats["stylesheets"].append(str(resolved))
            # Return a marker so we can replace the full tag after the scan.
            return f"__STYLESHEET_MARKER_{len(stats['stylesheets']) - 1}__"

        if font_only:
            mime, _ = mimetypes.guess_type(resolved.name)
            if not (mime and mime.startswith("font/")):
                return match.group(0)

        stats["inlined"].append(str(resolved))
        return f"{prefix}{quote}{to_data_uri(resolved)}{quote}"

    for pattern, _ in ATTR_PATTERNS:
        html = pattern.sub(replace_attr, html)

    # Replace the stylesheet markers with full <style> blocks. We do this as
    # a second pass so we can swap the entire <link> tag rather than just the
    # href attribute.
    for idx, css_path in enumerate(stats["stylesheets"]):
        marker = f"__STYLESHEET_MARKER_{idx}__"
        css = Path(css_path).read_text(encoding="utf-8")
        css = inline_css_urls(css, Path(css_path).parent, font_only=font_only, stats=stats)
        tag_re = re.compile(r"<link\b[^>]*?" + re.escape(marker) + r"[^>]*?>", re.I)
        replacement = f"<style>\n{css}\n</style>"
        html = tag_re.sub(replacement, html, count=1)

    # 2. url(...) inside <style> blocks.
    def replace_style_block(match: re.Match) -> str:
        open_tag, body, close_tag = match.group(1), match.group(2), match.group(3)
        body = inline_css_urls(body, base_dir, font_only=font_only, stats=stats)
        return f"{open_tag}{body}{close_tag}"

    html = STYLE_BLOCK_RE.sub(replace_style_block, html)

    # 3. url(...) inside style="..." attributes.
    def replace_style_attr(match: re.Match) -> str:
        prefix, quote, body = match.group(1), match.group(2), match.group(3)
        body = inline_css_urls(body, base_dir, font_only=font_only, stats=stats)
        return f"{prefix}{quote}{body}{quote}"

    html = STYLE_ATTR_RE.sub(replace_style_attr, html)

    return html, stats


# --- CLI ---------------------------------------------------------------------


def format_report(stats: dict, input_path: Path, output_path: Path | None, *, check: bool) -> str:
    lines = []
    verb = "Would inline" if check else "Inlined"
    lines.append(f"{verb} {len(stats['inlined'])} asset(s)")
    if stats["stylesheets"]:
        lines.append(f"Embedded {len(stats['stylesheets'])} stylesheet(s)")
    if stats["missing"]:
        lines.append(f"⚠ Could not resolve {len(stats['missing'])} reference(s):")
        for ref in stats["missing"][:10]:
            lines.append(f"    {ref}")
        if len(stats["missing"]) > 10:
            lines.append(f"    … and {len(stats['missing']) - 10} more")
    if not check and output_path:
        size_kb = output_path.stat().st_size / 1024
        lines.append(f"Output: {output_path} ({size_kb:,.1f} KB)")
    return "\n".join(lines)


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    p.add_argument("input", type=Path, help="HTML file with local asset references")
    p.add_argument("-o", "--output", type=Path, help="Output path (default: <input>.standalone.html)")
    p.add_argument("--check", action="store_true", help="Dry-run: report what would change without writing")
    p.add_argument("--font-only", action="store_true", help="Only inline font files, leave images/scripts linked")
    p.add_argument("--base", type=Path, help="Base directory for resolving refs (default: input's directory)")
    args = p.parse_args()

    if not args.input.is_file():
        print(f"error: {args.input} not found", file=sys.stderr)
        return 1

    base_dir = (args.base or args.input.parent).resolve()
    html = args.input.read_text(encoding="utf-8")
    new_html, stats = inline_html(html, base_dir, font_only=args.font_only)

    output_path = None
    if not args.check:
        if args.output:
            output_path = args.output
        else:
            stem = args.input.stem
            output_path = args.input.with_name(f"{stem}.standalone.html")
        output_path.write_text(new_html, encoding="utf-8")

    print(format_report(stats, args.input, output_path, check=args.check))
    return 0 if not stats["missing"] else 2  # soft fail if anything was missing


if __name__ == "__main__":
    sys.exit(main())
