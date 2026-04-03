---
name: handoff
description: Produce a context block and open the other Claude account in a new VS Code terminal with the context passed automatically. Use whenever the user says /handoff, "hand off", "running out of tokens", "continue in new session", "pass context", or wants to switch accounts.
allowed-tools: Bash
---

## Setup context

This machine uses two separate Claude Code commands:
- `claude` → work account (`~/.claude/`)
- `claude-bfc` → personal account (`~/.claude-bfc/`)

## What to do

1. **Detect current account** by checking `CLAUDE_CONFIG_DIR` env var:
   - If contains `claude-bfc` → currently personal → target is `claude` (work)
   - Otherwise → currently work → target is `claude-bfc` (personal)

2. **Synthesize context** from the conversation (omit empty sections):
   - Goal (1-2 sentences)
   - Context (repo, branch, key files)
   - Decisions made
   - Work done
   - Next steps
   - Open questions

3. **Run this bash** (fill in context and target):

```bash
# Write context to temp file
CONTEXT_FILE=$(mktemp /tmp/claude_handoff_XXXXXX)
cat > "$CONTEXT_FILE" << 'CTXEOF'
[HANDOFF CONTEXT]
...fill in synthesized context...
---
Resume from here. You have full context above.
CTXEOF

# Determine target command
if [[ "${CLAUDE_CONFIG_DIR:-}" == *"claude-bfc"* ]]; then
  TARGET="claude"
  LABEL="work"
else
  TARGET="claude-bfc"
  LABEL="personal"
fi

# Write launcher script
LAUNCHER=$(mktemp /tmp/claude_launch_XXXXXX)
cat > "$LAUNCHER" << EOF
#!/bin/bash
source ~/.zshrc 2>/dev/null
cd $(pwd)
$TARGET "\$(cat $CONTEXT_FILE)"
EOF
chmod +x "$LAUNCHER"

# Open new VS Code terminal via command palette and run launcher
osascript << ASEOF
tell application "Visual Studio Code"
    activate
end tell
delay 1
tell application "System Events"
    tell process "Code"
        set frontmost to true
    end tell
    delay 0.5
    keystroke "p" using {command down, shift down}
    delay 1
    keystroke "Terminal: Create New Terminal"
    delay 1
    key code 36
    delay 2
    keystroke "bash $LAUNCHER"
    delay 0.3
    key code 36
end tell
ASEOF

echo "Launched $LABEL account in new VS Code terminal."
```

4. Tell the user: "Handed off to [work/personal] account in VS Code terminal."

## Tone

Every bullet under 15 words. Be ruthlessly concise.
