#!/usr/bin/env python3
"""PreToolUse guard for Bash: deny public GitHub writes to repos you don't own.

Opening a PR, issue or comment on someone else's repo publishes under your
name and can't be taken back quietly, so the agent must ask first. Denying
here makes that deterministic: the reason tells the agent to ask, and on
approval you run the command yourself with `! gh ...`.

Denied:
  gh repo fork                                   always
  gh pr|issue <write-subcommand>                 target owner not allowed
  gh api <write> repos/<owner>/...               target owner not allowed

Target owner: -R/--repo, else GH_REPO=, else every GitHub remote of the
directory the command runs in (last `cd` wins). Conservative: one foreign
remote is enough to deny. Not covered: `gh api graphql` mutations.

Allowed owners: $CLAUDE_GH_OWNERS (space/comma separated), default below.
"""

import json
import os
import re
import shlex
import subprocess
import sys

DEFAULT_OWNERS = "riethmayer earlybirdvc"
WRITE_SUBCOMMANDS = {
    "create", "comment", "review", "close", "reopen", "edit", "merge",
    "lock", "unlock", "delete", "transfer", "develop", "ready",
}
FIELD_FLAGS = {"-f", "-F", "--field", "--raw-field", "--input"}
REMOTE_RE = re.compile(r"github\.com[:/]+([^/]+)/")


def allowed_owners() -> set[str]:
    raw = os.environ.get("CLAUDE_GH_OWNERS", DEFAULT_OWNERS)
    return {o.lower() for o in re.split(r"[\s,]+", raw) if o}


def remote_owners(cwd: str) -> set[str]:
    try:
        out = subprocess.run(
            ["git", "-C", cwd, "remote", "-v"],
            capture_output=True, text=True, timeout=3,
        ).stdout
    except Exception:
        return set()
    return {m.group(1).lower() for m in REMOTE_RE.finditer(out)}


def segments(command: str) -> list[list[str]]:
    lex = shlex.shlex(command, posix=True, punctuation_chars=";&|\n")
    lex.whitespace_split = True
    segs, cur = [], []
    try:
        for tok in lex:
            if tok and set(tok) <= set(";&|\n"):
                segs.append(cur)
                cur = []
            else:
                cur.append(tok)
    except ValueError:  # unbalanced quotes: fall back to plain split
        return [command.split()]
    segs.append(cur)
    return [s for s in segs if s]


def repo_flag(args: list[str]) -> str | None:
    for i, a in enumerate(args):
        if a in ("-R", "--repo") and i + 1 < len(args):
            return args[i + 1]
        if a.startswith("--repo="):
            return a.split("=", 1)[1]
        if a.startswith("-R") and len(a) > 2:
            return a[2:]
    return None


def check(seg: list[str], cwd: str, env_repo: str | None) -> str | None:
    """Return a denial reason for one command segment, or None."""
    if not seg or seg[0] != "gh":
        return None
    args = seg[1:]
    if args[:2] == ["repo", "fork"]:
        return "gh repo fork creates a public fork"

    targets: set[str] = set()
    if len(args) >= 2 and args[0] in ("pr", "issue") and args[1] in WRITE_SUBCOMMANDS:
        repo = repo_flag(args) or env_repo
        targets = {repo.split("/")[0].lower()} if repo else remote_owners(cwd)
        action = f"gh {args[0]} {args[1]}"
    elif args[:1] == ["api"]:
        method = "GET"
        for i, a in enumerate(args):
            if a in ("-X", "--method") and i + 1 < len(args):
                method = args[i + 1].upper()
            elif a.startswith("--method="):
                method = a.split("=", 1)[1].upper()
            elif a.startswith("-X") and len(a) > 2:
                method = a[2:].upper()
        wrote_fields = any(a in FIELD_FLAGS or a.split("=")[0] in FIELD_FLAGS for a in args)
        explicit = any(a in ("-X", "--method") or a.startswith(("-X", "--method=")) for a in args)
        if wrote_fields and not explicit:
            method = "POST"
        if method == "GET":
            return None
        path = next((a for a in args[1:] if a.lstrip("/").startswith("repos/")), None)
        if not path:
            return None
        owner = path.lstrip("/").split("/")[1]
        targets = remote_owners(cwd) if owner == "{owner}" else {owner.lower()}
        action = f"gh api {method} {path}"
    else:
        return None

    foreign = targets - allowed_owners()
    if foreign:
        return f"{action} targets {', '.join(sorted(foreign))}, not an allowed owner"
    return None


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    command = (data.get("tool_input") or {}).get("command") or ""
    if "gh" not in command:
        return
    cwd = data.get("cwd") or os.getcwd()

    for seg in segments(command):
        env_repo = None
        while seg and re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", seg[0]):
            key, _, val = seg[0].partition("=")
            if key == "GH_REPO":
                env_repo = val
            seg = seg[1:]
        if seg[:1] == ["cd"] and len(seg) > 1:
            cwd = os.path.join(cwd, os.path.expanduser(seg[1]))
            continue
        reason = check(seg, cwd, env_repo)
        if reason:
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": (
                        f"guard-foreign-github: {reason}. This publishes to someone "
                        "else's repo. Ask the user first; if they approve, they run "
                        "it themselves with `! <command>`."
                    ),
                },
                "systemMessage": f"⛔ guard-foreign-github: {reason}",
            }))
            return


if __name__ == "__main__":
    main()
