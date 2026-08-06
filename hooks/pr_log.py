#!/usr/bin/env python3
"""PostToolUse hook: log gh pr create calls to CLAUDE.local.md."""
import json
import re
import sys
from datetime import date
from pathlib import Path

CLAUDE_LOCAL_MD = Path("/Users/bforbesc/Desktop/CODE/dna-clustering/CLAUDE.local.md")

data = json.load(sys.stdin)
command = data.get("tool_input", {}).get("command", "")

if "gh pr create" not in command:
    sys.exit(0)

response = data.get("tool_response", {})
output = response.get("output", response.get("stdout", "")) if isinstance(response, dict) else str(response)

url_match = re.search(r"https://github\.com/\S+/pull/\d+", output)
if not url_match:
    sys.exit(0)
url = url_match.group(0)

title_match = re.search(r'--title\s+"([^"]+)"', command) or re.search(r"--title\s+'([^']+)'", command)
title = title_match.group(1) if title_match else "(no title)"

today = date.today().isoformat()
entry = f"- {today}: [{title}]({url})\n"

content = CLAUDE_LOCAL_MD.read_text()
if "## PR Log" in content:
    content = content.replace("## PR Log\n", f"## PR Log\n{entry}", 1)
else:
    content = content.rstrip() + f"\n\n## PR Log\n{entry}"

CLAUDE_LOCAL_MD.write_text(content)
