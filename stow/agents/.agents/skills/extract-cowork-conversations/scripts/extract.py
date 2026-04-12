#!/usr/bin/env python3
"""Extract and format Claude Cowork conversation threads from local audit.jsonl files.

Usage:
    python extract.py list                           # List all sessions
    python extract.py search <keyword>               # Search sessions by keyword
    python extract.py extract <session-id>            # Extract full conversation
    python extract.py extract <session-id> --users    # User messages only
    python extract.py export <session-id> <outfile>   # Export to markdown file
    python extract.py export-all <outdir>             # Export all sessions
"""

import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path

BASE = Path.home() / "Library" / "Application Support" / "Claude" / "local-agent-mode-sessions"


def find_sessions():
    """Walk the session directory and yield (metadata_path, audit_path) tuples."""
    if not BASE.exists():
        return

    for workspace in BASE.iterdir():
        if not workspace.is_dir() or workspace.name == "skills-plugin":
            continue
        for project in workspace.iterdir():
            if not project.is_dir():
                continue
            for item in sorted(project.iterdir()):
                if item.suffix == ".json" and item.stem.startswith("local_"):
                    session_id = item.stem
                    audit_dir = project / session_id
                    audit_path = audit_dir / "audit.jsonl" if audit_dir.is_dir() else None
                    yield item, audit_path


def load_metadata(path):
    """Load session metadata from JSON file."""
    with open(path) as f:
        data = json.load(f)
    ts = data.get("createdAt", 0)
    created = datetime.fromtimestamp(ts / 1000).strftime("%Y-%m-%d %H:%M") if ts else "unknown"
    return {
        "session_id": data.get("sessionId", ""),
        "title": data.get("title", "untitled"),
        "created": created,
        "created_ts": ts,
        "model": data.get("model", ""),
        "initial_message": str(data.get("initialMessage", ""))[:150],
        "cwd": data.get("cwd", ""),
    }


def clean_content(content):
    """Strip uploaded file tags and clean up content."""
    if not isinstance(content, str):
        return ""
    clean = re.sub(r"<uploaded_files>.*?</uploaded_files>", "[FILES UPLOADED]", content, flags=re.DOTALL)
    return clean.strip()


def extract_messages(audit_path, users_only=False, include_tools=False):
    """Extract conversation messages from audit.jsonl."""
    messages = []
    if not audit_path or not audit_path.exists():
        return messages

    with open(audit_path) as f:
        for line in f:
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            entry_type = entry.get("type", "")

            if entry_type == "user":
                content = entry.get("message", {}).get("content", "")
                clean = clean_content(content)
                if clean:
                    messages.append(("user", clean))

            elif entry_type == "assistant" and not users_only:
                content = entry.get("message", {}).get("content", "")
                if isinstance(content, list):
                    text_parts = []
                    for block in content:
                        if isinstance(block, dict):
                            if block.get("type") == "text":
                                text_parts.append(block.get("text", ""))
                            elif block.get("type") == "tool_use" and include_tools:
                                name = block.get("name", "unknown")
                                text_parts.append(f"[TOOL: {name}]")
                    if text_parts:
                        messages.append(("assistant", "\n".join(text_parts)))
                elif isinstance(content, str) and content.strip():
                    messages.append(("assistant", content))

    return messages


def cmd_list():
    """List all sessions with metadata."""
    sessions = []
    for meta_path, audit_path in find_sessions():
        meta = load_metadata(meta_path)
        has_audit = audit_path is not None and audit_path.exists()
        audit_size = audit_path.stat().st_size if has_audit else 0
        meta["has_audit"] = has_audit
        meta["audit_size_kb"] = round(audit_size / 1024)
        sessions.append(meta)

    sessions.sort(key=lambda s: s["created_ts"])

    print(f"Found {len(sessions)} sessions\n")
    for s in sessions:
        audit_info = f" [{s['audit_size_kb']}KB]" if s["has_audit"] else " [no audit]"
        print(f"  {s['created']}  {s['title']}{audit_info}")
        print(f"             {s['session_id']}")
        if s["initial_message"]:
            preview = s["initial_message"][:100].replace("\n", " ")
            print(f"             > {preview}")
        print()


def cmd_search(keyword):
    """Search sessions by keyword in title, initial message, or audit content."""
    keyword_lower = keyword.lower()
    results = []

    for meta_path, audit_path in find_sessions():
        meta = load_metadata(meta_path)

        # Search metadata
        meta_text = f"{meta['title']} {meta['initial_message']}".lower()
        if keyword_lower in meta_text:
            results.append((meta, "metadata"))
            continue

        # Search audit content (read line by line to handle large files)
        if audit_path and audit_path.exists():
            with open(audit_path) as f:
                for line in f:
                    if keyword_lower in line.lower():
                        results.append((meta, "content"))
                        break

    print(f"Found {len(results)} sessions matching '{keyword}'\n")
    for meta, match_type in results:
        print(f"  {meta['created']}  {meta['title']} (match: {match_type})")
        print(f"             {meta['session_id']}")
        print()


def cmd_extract(session_id, users_only=False):
    """Extract and print conversation for a session."""
    for meta_path, audit_path in find_sessions():
        meta = load_metadata(meta_path)
        if meta["session_id"] == session_id or session_id in meta["session_id"]:
            print(f"# {meta['title']}")
            print(f"Created: {meta['created']}")
            print(f"Session: {meta['session_id']}")
            print()

            messages = extract_messages(audit_path, users_only=users_only)
            if not messages:
                print("No messages found (audit file may be missing or encrypted)")
                return

            for i, (role, msg) in enumerate(messages, 1):
                if users_only:
                    print(f"[{i}] {msg}\n")
                else:
                    label = "**User:**" if role == "user" else "**Assistant:**"
                    print(f"{label}\n\n{msg}\n\n---\n")
            return

    print(f"Session '{session_id}' not found")


def cmd_export(session_id, output_path):
    """Export a session to a markdown file."""
    for meta_path, audit_path in find_sessions():
        meta = load_metadata(meta_path)
        if meta["session_id"] == session_id or session_id in meta["session_id"]:
            messages = extract_messages(audit_path)
            if not messages:
                print(f"No messages found for {session_id}")
                return

            with open(output_path, "w") as f:
                f.write(f"# {meta['title']}\n\n")
                f.write(f"- **Created:** {meta['created']}\n")
                f.write(f"- **Session:** {meta['session_id']}\n\n")
                f.write("---\n\n")

                for role, msg in messages:
                    label = "User" if role == "user" else "Assistant"
                    f.write(f"## {label}\n\n{msg}\n\n---\n\n")

            print(f"Exported {len(messages)} messages to {output_path}")
            return

    print(f"Session '{session_id}' not found")


def cmd_export_all(output_dir):
    """Export all sessions to a directory."""
    os.makedirs(output_dir, exist_ok=True)
    count = 0

    for meta_path, audit_path in find_sessions():
        if not audit_path or not audit_path.exists():
            continue
        meta = load_metadata(meta_path)
        messages = extract_messages(audit_path)
        if not messages:
            continue

        safe_title = re.sub(r"[^\w\s-]", "", meta["title"]).strip().replace(" ", "-").lower()[:50]
        filename = f"{meta['created'][:10]}_{safe_title}.md"
        filepath = os.path.join(output_dir, filename)

        with open(filepath, "w") as f:
            f.write(f"# {meta['title']}\n\n")
            f.write(f"- **Created:** {meta['created']}\n")
            f.write(f"- **Session:** {meta['session_id']}\n\n")
            f.write("---\n\n")
            for role, msg in messages:
                label = "User" if role == "user" else "Assistant"
                f.write(f"## {label}\n\n{msg}\n\n---\n\n")

        count += 1
        print(f"  Exported: {filename}")

    print(f"\nExported {count} sessions to {output_dir}")


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return

    cmd = sys.argv[1]

    if cmd == "list":
        cmd_list()
    elif cmd == "search" and len(sys.argv) >= 3:
        cmd_search(" ".join(sys.argv[2:]))
    elif cmd == "extract" and len(sys.argv) >= 3:
        users_only = "--users" in sys.argv
        cmd_extract(sys.argv[2], users_only=users_only)
    elif cmd == "export" and len(sys.argv) >= 4:
        cmd_export(sys.argv[2], sys.argv[3])
    elif cmd == "export-all" and len(sys.argv) >= 3:
        cmd_export_all(sys.argv[2])
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
