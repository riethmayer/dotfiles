#!/usr/bin/env python3
"""PreToolUse hook: reject em-dash (U+2014) in content being written.

Checks ONLY the new content of Write/Edit/MultiEdit (content / new_string /
edits[].new_string), never old_string, so pre-existing em-dashes in a file do
not trip it. Exit 2 blocks the tool call and feeds stderr back to the model.
Any parse failure exits 0 so unrelated tools are never wedged.
"""
import sys, json

EMDASH = "—"

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

ti = data.get("tool_input") or {}
parts = []
if isinstance(ti.get("content"), str):
    parts.append(ti["content"])
if isinstance(ti.get("new_string"), str):
    parts.append(ti["new_string"])
for e in (ti.get("edits") or []):
    if isinstance(e, dict) and isinstance(e.get("new_string"), str):
        parts.append(e["new_string"])

if EMDASH in "\n".join(parts):
    sys.stderr.write(
        "Em-dash (U+2014) detected in content you are writing. "
        "Jan does not use em-dashes. Replace with ' - ', ':', ',', or "
        "rephrase the sentence, then retry.\n"
    )
    sys.exit(2)

sys.exit(0)
