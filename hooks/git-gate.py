#!/usr/bin/env python3
"""
Git gate hook — blocks write git operations and asks user for approval.
Reads tool input JSON from stdin, outputs Claude Code hook response JSON to stdout.
"""
import sys
import json
import re

BLOCKED = [
    "git push",
    "git pull",
    "git commit",
    "git branch -d",
    "git branch -D",
    "git reset",
    "git rebase",
    "git merge",
    "git tag -d",
    "git tag -f",
    "git checkout --",
    "git checkout .",
    "git stash drop",
    "git clean",
    "git restore",
    "gh pr create",
    "gh pr merge",
    "gh pr close",
]


def find_blocked(cmd):
    """Return the first blocked pattern matched, or None."""
    parts = re.split(r"\s*[;&|]+\s*", cmd)
    for part in parts:
        stripped = part.strip()
        for pattern in BLOCKED:
            if stripped.startswith(pattern):
                return pattern
    return None


try:
    data = json.load(sys.stdin)
    cmd = data.get("tool_input", {}).get("command", "") or data.get("command", "")
    matched = find_blocked(cmd)
    if matched:
        # "ask" shows an approve/deny prompt and lets Claude carry on either way.
        # "continue": False used to halt the turn without stopping the command.
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "ask",
                "permissionDecisionReason": f"{matched} writes to the repo or remote.",
            }
        }))
except Exception:
    pass
