# forbes-crew

Personal repository of all Claude Code skills, plugins, agents, and config.
Use this as the source of truth to maintain and restore your Claude Code setup.

---

## File Locations

### General (any user)

| File | Path |
|------|------|
| Global instructions | `~/.claude/CLAUDE.md` |
| Settings & hooks | `~/.claude/settings.json` |
| Custom skills | `~/.claude/skills/<skill-name>/SKILL.md` |
| Plugin cache | `~/.claude/plugins/cache/claude-plugins-official/<plugin>/` |
| Memory index | `~/.claude/projects/<project-path>/memory/MEMORY.md` |

### This machine (`bforbesc`)

| File | Absolute path |
|------|---------------|
| Global instructions | `/Users/bforbesc/.claude/CLAUDE.md` |
| Settings & hooks | `/Users/bforbesc/.claude/settings.json` |
| Custom skills | `/Users/bforbesc/.claude/skills/` |
| Plugin cache | `/Users/bforbesc/.claude/plugins/cache/claude-plugins-official/` |

---

## Repo Structure

```
forbes-crew/
├── config/              # Source of truth for ~/.claude/CLAUDE.md and settings.json
│   ├── CLAUDE.md
│   └── settings.json
├── skills/              # Custom user-created skills → ~/.claude/skills/
│   ├── check/
│   ├── handoff/
│   ├── pr/
│   ├── pr-comments/
│   ├── resolve-conflicts/
│   └── switch/
└── plugins/             # Installed plugin snapshots → ~/.claude/plugins/cache/
    └── installed_plugins.json   # Manifest with versions and commit SHAs
```

---

## Applying Config

```bash
# Copy global instructions and settings
cp config/CLAUDE.md ~/.claude/CLAUDE.md
cp config/settings.json ~/.claude/settings.json

# Copy custom skills
mkdir -p ~/.claude/skills
cp -r skills/* ~/.claude/skills/
```

> Plugins are fetched from the marketplace — reinstall them via Claude Code rather than copying the cache.
> Use `plugins/installed_plugins.json` as the reference list.

---

## Active Hooks

| Event | Trigger | Action |
|-------|---------|--------|
| `PreToolUse → Bash` | Any `git commit` command | Runs `/check` skill to catch bugs before committing |
| `PostToolUse → AskUserQuestion` | Claude asks a question | Speaks `"Need your input"` aloud |
| `Stop` | Claude finishes a response | Speaks `"Completed..."` aloud |

---

## Custom Skills (`skills/`)

Invoke with `/skill-name` in any Claude Code session.

| Skill | Description |
|-------|-------------|
| `check` | Reviews staged/unstaged changes for bugs, broken references, and runtime errors before committing. Ignores style. |
| `handoff` | Switches accounts while preserving conversation context, or produces a context block to continue in a new session. |
| `pr` | Stages changes, commits, pushes, and opens a new PR or adds a follow-up comment to an existing one. |
| `pr-comments` | Fetches all comments and reviews on the current PR, summarizes them, and recommends which to address. |
| `resolve-conflicts` | Summarizes merge conflicts, resolves unambiguous ones automatically, and asks about ambiguous ones. |
| `switch` | Switches Claude Code to a different account (logout → login) without passing context. |

---

## Plugins (`plugins/`)

Marketplace plugins from `claude-plugins-official`. Each adds skills, agents, commands, or hooks.

| Plugin | What it provides |
|--------|-----------------|
| `claude-code-setup` | `claude-automation-recommender` — analyzes a codebase and recommends hooks, subagents, skills, and MCP servers |
| `claude-md-management` | `claude-md-improver` skill + `/revise-claude-md` command — audits and improves CLAUDE.md files |
| `code-review` | `/code-review` command — comprehensive inline code review |
| `code-simplifier` | `code-simplifier` agent — simplifies recently changed code for clarity and maintainability |
| `commit-commands` | `/commit`, `/commit-push-pr`, `/clean_gone` — git workflow shortcuts |
| `context7` | Live documentation fetching for any library, framework, or SDK via MCP |
| `explanatory-output-style` | SessionStart hook that enables educational insight mode with `★ Insight` blocks |
| `github` | GitHub MCP integration — create issues, manage PRs, search repos directly from Claude |
| `playwright` | Browser automation MCP integration |
| `pr-review-toolkit` | `code-reviewer`, `silent-failure-hunter`, `comment-analyzer`, `pr-test-analyzer`, `type-design-analyzer` agents + `/review-pr` command |
| `skill-creator` | `skill-creator` skill — create, improve, and benchmark skills with evals |
| `superpowers` | Brainstorming, TDD, systematic debugging, git worktrees, subagent-driven development, and more |
