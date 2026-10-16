#!/bin/sh
# sync.sh — pull live ~/.claude config into this repo
# Run this whenever you've changed settings, CLAUDE.md, skills or agents.

REPO="$(cd "$(dirname "$0")" && pwd)"
CLAUDE="$HOME/.claude"

# Everything this repo publishes is named here. Nothing outside these lists is
# copied, so a new skill or agent stays private until you add it.
SKILLS="agent-developer agent-scaffold freeze-plan humanizer open-pr pay-tech-debt resolve-pr-conflicts review-pr walkthrough"
AGENTS="explorer.md code-reviewer.md comment-analyzer.md implementer.md security-scanner.md silent-failure-hunter.md test-writer.md"
# settings.json keeps only plugins from these marketplaces, so a private
# marketplace never shows up here by name.
MARKETPLACES="claude-plugins-official openai-codex synced"

# Deliberately absent, and not an oversight:
#   employer skills and plugins — carry an employer's internal material, such as
#     a take-home challenge and its grading rubric. This repo is public.
#   onboarding — describes where a named employer's engagement context lives.
#   projects/*/memory/ — names colleagues and records private feedback.
#   settings.local.json — machine-local path allowlists.

cp "$CLAUDE/CLAUDE.md"               "$REPO/config/CLAUDE.md"
MARKETPLACES="$MARKETPLACES" python3 - "$CLAUDE/settings.json" "$REPO/config/settings.json" <<'PY'
import json, os, sys
keep = os.environ["MARKETPLACES"].split()
settings = json.load(open(sys.argv[1]))
plugins = settings.get("enabledPlugins", {})
settings["enabledPlugins"] = {k: v for k, v in plugins.items() if k.split("@")[-1] in keep}
with open(sys.argv[2], "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")
PY
cp "$CLAUDE/statusline-command.sh"   "$REPO/config/statusline-command.sh"

for skill in $SKILLS; do
  src="$CLAUDE/skills/$skill/SKILL.md"
  if [ -f "$src" ]; then
    mkdir -p "$REPO/skills/$skill"
    cp "$src" "$REPO/skills/$skill/SKILL.md"
  fi
  # A skill's SKILL.md may point at files under references/, so those travel too.
  if [ -d "$CLAUDE/skills/$skill/references" ]; then
    mkdir -p "$REPO/skills/$skill/references"
    cp -R "$CLAUDE/skills/$skill/references/." "$REPO/skills/$skill/references/"
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

if [ -n "$stale" ]; then
  echo "Tracked here but gone from ~/.claude:$stale"
  echo "Either it moved and this repo is wrong, or you meant to delete it: git rm -r <path>"
fi

echo "Synced. Review with: git diff"
echo "Commit with:         git add -A && git commit -m 'sync config'"
