#!/bin/sh
# sync.sh — pull live ~/.claude config into this repo
# Run this whenever you've changed settings, CLAUDE.md, or skills

REPO="$(cd "$(dirname "$0")" && pwd)"
CLAUDE="$HOME/.claude"

cp "$CLAUDE/CLAUDE.md"               "$REPO/config/CLAUDE.md"
cp "$CLAUDE/settings.json"           "$REPO/config/settings.json"
cp "$CLAUDE/statusline-command.sh"   "$REPO/config/statusline-command.sh"

# Sync custom skills (only files already tracked — won't add new ones automatically)
for skill in check freeze-plan handoff pr pr-comments prep-pr resolve-conflicts triage walkthrough; do
  src="$CLAUDE/skills/$skill/SKILL.md"
  dst="$REPO/skills/$skill/SKILL.md"
  if [ -f "$src" ]; then
    mkdir -p "$REPO/skills/$skill"
    cp "$src" "$dst"
  fi
done

echo "Synced. Review with: git diff"
echo "Commit with:         git add -A && git commit -m 'sync config'"
