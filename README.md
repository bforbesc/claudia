# forbes-crew

Hey — this is where I keep my Claude Code setup. Skills, plugins, config, the whole thing.

I update it as I go. It's my source of truth, but feel free to steal whatever's useful. Enjoy.

---

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
├── config/              # Source of truth for ~/.claude/ config files
│   ├── CLAUDE.md            # Global instructions for all projects
│   ├── settings.json        # Model, hooks, permissions, plugins
│   └── statusline-command.sh  # Custom status bar script
└── skills/              # Custom skills → ~/.claude/skills/
    ├── check/
    ├── handoff/
    ├── pr/
    ├── pr-comments/
    ├── resolve-conflicts/
    └── switch/
```

---

## Config (`config/`)

### `CLAUDE.md` → `~/.claude/CLAUDE.md`

The global instruction file loaded at the start of every Claude Code session. Because it's prompt-cached, rules placed here are effectively free after the first turn — no need to repeat preferences in every message.

Covers: permissions, code philosophy, token efficiency, engineering communication style, plan mode behavior, safety rules, agent routing with model assignments, and more.

### `settings.json` → `~/.claude/settings.json`

Claude Code runtime config. Key things set here:

- **Model**: `sonnet` by default; subagents use `opus` or `haiku` per task (set in CLAUDE.md)
- **Hooks**: automated behaviors that run on specific events (see below)
- **Permissions**: tools that auto-approve without prompting (`Read`, `Edit`, `Write`, `Glob`, `Grep`, `Agent`, web tools)
- **Plugins**: which marketplace plugins are enabled

### `statusline-command.sh` → `~/.claude/statusline-command.sh`

A shell script that powers the Claude Code status bar. Displays:

- **Active model** name in cyan
- **Context window usage** as a color-coded progress bar (green → orange → red as it fills)
- **Rate limit usage** for the 5-hour and 7-day windows, shown once data is available

The bar turns orange at 50% and red at 80% so you can see at a glance when you're burning through context or hitting limits.

---

## Applying Config

```bash
# Global instructions and settings
cp config/CLAUDE.md ~/.claude/CLAUDE.md
cp config/settings.json ~/.claude/settings.json

# Status bar script
cp config/statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh

# Custom skills
mkdir -p ~/.claude/skills
cp -r skills/* ~/.claude/skills/
```

---

## Plugins

Not stored here — the code belongs to the marketplace authors. Install them directly in Claude Code with `/plugins`.

| Plugin | What it does |
|--------|-------------|
| `explanatory-output-style` | Adds educational `★ Insight` blocks to responses |
| `code-simplifier` | Simplifies recently changed code for clarity |
| `claude-md-management` | Audits and improves CLAUDE.md files |
| `skill-creator` | Create, improve, and benchmark skills |
| `commit-commands` | `/commit`, `/commit-push-pr`, `/clean_gone` shortcuts |
| `pr-review-toolkit` | Full PR review suite with specialized agents |
| `claude-code-setup` | Recommends automations for your workflow |
| `context7` | Live library/framework docs via MCP |
| `code-review` | Inline code review command |
| `github` | GitHub MCP — issues, PRs, repos from Claude |
| `playwright` | Browser automation via MCP |
| `superpowers` | Brainstorming, TDD, debugging, worktrees, and more |

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
