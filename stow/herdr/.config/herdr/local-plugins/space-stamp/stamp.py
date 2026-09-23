"""space-stamp hook: stamp id metadata and the treehouse slot prefix.

Input: HERDR_PLUGIN_EVENT_JSON (workspace_created). Uses HERDR_BIN_PATH so it
talks to the session that fired the event. Stdlib only.
"""
import json
import os
import re
import subprocess
import sys

SLOT = re.compile(r"/\.treehouse/[^/]+/(\d+)/[^/]+/?$")


def herdr(*args: str) -> dict:
    bin_path = os.environ.get("HERDR_BIN_PATH") or "herdr"
    out = subprocess.run([bin_path, *args], capture_output=True, text=True, timeout=10)
    if out.returncode != 0:
        raise RuntimeError(f"herdr {args[0]} {args[1]}: {out.stderr.strip() or out.stdout.strip()}")
    return json.loads(out.stdout) if out.stdout.strip() else {}


def main() -> int:
    event = json.loads(os.environ.get("HERDR_PLUGIN_EVENT_JSON") or "{}")
    ws = ((event.get("data") or {}).get("workspace") or {})
    ws_id = ws.get("workspace_id")
    if not ws_id:
        print("space-stamp: no workspace_id in event", file=sys.stderr)
        return 0

    # Re-read: the event is a snapshot, and the creator may already have
    # stamped or renamed the space.
    live = herdr("workspace", "get", ws_id)["result"]["workspace"]
    label = live.get("label") or ""
    tokens = live.get("tokens") or {}

    if tokens.get("id") != ws_id:
        herdr("workspace", "report-metadata", ws_id, "--source", "orchestrator", "--token", f"id={ws_id}")
        print(f"space-stamp: {ws_id} id stamped")

    checkout = (live.get("worktree") or {}).get("checkout_path") or ""
    m = SLOT.search(checkout)
    if m:
        slot = m.group(1)
        if label and not label.startswith(f"{slot} "):
            herdr("workspace", "rename", ws_id, f"{slot} {label}")
            print(f"space-stamp: {ws_id} renamed to '{slot} {label}'")
    return 0


if __name__ == "__main__":
    sys.exit(main())
