#!/bin/sh
# sync.sh — pull live ~/.claude config into this repo
# Run this whenever you've changed settings, CLAUDE.md, or skills

REPO="$(cd "$(dirname "$0")" && pwd)"
CLAUDE="$HOME/.claude"

cp "$CLAUDE/CLAUDE.md"               "$REPO/config/CLAUDE.md"
cp "$CLAUDE/settings.json"           "$REPO/config/settings.json"
cp "$CLAUDE/statusline-command.sh"   "$REPO/config/statusline-command.sh"

# Sync custom skills. Add a name to this list when you create a new skill —
# nothing outside the list is copied.
for skill in check freeze-plan handoff pr pr-comments prep-pr resolve-conflicts triage walkthrough; do
  src="$CLAUDE/skills/$skill/SKILL.md"
  dst="$REPO/skills/$skill/SKILL.md"
  if [ -f "$src" ]; then
    mkdir -p "$REPO/skills/$skill"
    cp "$src" "$dst"
  fi
done

# Sync hook scripts. settings.json points at these by path, so a machine
# without them silently loses the behaviour.
for hook in git-gate.py pr_log.py; do
  if [ -f "$CLAUDE/hooks/$hook" ]; then
    mkdir -p "$REPO/hooks"
    cp "$CLAUDE/hooks/$hook" "$REPO/hooks/$hook"
  fi
done

# Sync subagent definitions.
for agent in Explore.md; do
  if [ -f "$CLAUDE/agents/$agent" ]; then
    mkdir -p "$REPO/agents"
    cp "$CLAUDE/agents/$agent" "$REPO/agents/$agent"
  fi
done

echo "Synced. Review with: git diff"
echo "Commit with:         git add -A && git commit -m 'sync config'"
