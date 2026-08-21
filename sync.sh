#!/bin/sh
# sync.sh — pull live ~/.claude config into this repo
# Run this whenever you've changed settings, CLAUDE.md, skills, hooks or agents.

REPO="$(cd "$(dirname "$0")" && pwd)"
CLAUDE="$HOME/.claude"

# Everything this repo publishes is named here. Nothing outside these lists is
# copied, so a new skill, hook or agent stays private until you add it.
SKILLS="agent-developer agent-scaffold freeze-plan handoff humanizer open-pr pay-tech-debt resolve-pr-conflicts review-pr walkthrough"
HOOKS="git-gate.py"
AGENTS="Explore.md code-reviewer.md comment-analyzer.md implementer.md security-scanner.md silent-failure-hunter.md test-writer.md"

# Deliberately absent, and not an oversight:
#   loka-analyze-candidate-submission — carries an employer's take-home challenge
#     and its grading rubric. This repo is public.
#   onboarding — describes where a named employer's engagement context lives.
#   projects/*/memory/ — names colleagues and records private feedback.
#   settings.local.json — machine-local path allowlists.

cp "$CLAUDE/CLAUDE.md"               "$REPO/config/CLAUDE.md"
cp "$CLAUDE/settings.json"           "$REPO/config/settings.json"
cp "$CLAUDE/statusline-command.sh"   "$REPO/config/statusline-command.sh"

for skill in $SKILLS; do
  src="$CLAUDE/skills/$skill/SKILL.md"
  if [ -f "$src" ]; then
    mkdir -p "$REPO/skills/$skill"
    cp "$src" "$REPO/skills/$skill/SKILL.md"
  fi
done

# settings.json points at hooks by path, so a machine without them silently
# loses the behaviour.
for hook in $HOOKS; do
  if [ -f "$CLAUDE/hooks/$hook" ]; then
    mkdir -p "$REPO/hooks"
    cp "$CLAUDE/hooks/$hook" "$REPO/hooks/$hook"
  fi
done

for agent in $AGENTS; do
  if [ -f "$CLAUDE/agents/$agent" ]; then
    mkdir -p "$REPO/agents"
    cp "$CLAUDE/agents/$agent" "$REPO/agents/$agent"
  fi
done

# Copying never deletes, so a skill you renamed or dropped lives on here as a
# tracked file nothing produced. Report it rather than pruning: deleting from
# the repo is a decision, not a side effect of a sync.
stale=""
for tracked in "$REPO"/skills/*/; do
  name=$(basename "$tracked")
  [ -d "$CLAUDE/skills/$name" ] || stale="$stale skills/$name"
done
for tracked in "$REPO"/agents/*.md; do
  name=$(basename "$tracked")
  [ -f "$CLAUDE/agents/$name" ] || stale="$stale agents/$name"
done
for tracked in "$REPO"/hooks/*; do
  name=$(basename "$tracked")
  [ -f "$CLAUDE/hooks/$name" ] || stale="$stale hooks/$name"
done

if [ -n "$stale" ]; then
  echo "Tracked here but gone from ~/.claude:$stale"
  echo "Either it moved and this repo is wrong, or you meant to delete it: git rm -r <path>"
fi

echo "Synced. Review with: git diff"
echo "Commit with:         git add -A && git commit -m 'sync config'"
