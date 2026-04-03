# Forbes' Crew 🤖

My Claude Code setup — because even AI needs a good manager.

This is where I keep my config, skills, and plugins. I update it as I go. It's my source of truth, but feel free to steal whatever's useful. Enjoy.

## Where things live

All Claude Code config lives under `~/.claude/`:

| File | Purpose |
|------|---------|
| `~/.claude/CLAUDE.md` | Global instructions loaded at the start of every session |
| `~/.claude/settings.json` | Model, hooks, permissions, enabled plugins |
| `~/.claude/statusline-command.sh` | Custom status bar script |
| `~/.claude/skills/<name>/SKILL.md` | Custom skills, invoked with `/name` |
| `~/.claude/projects/<path>/memory/MEMORY.md` | Per-project memory index |

## What's in this repo

```
forbes-crew/
├── config/
│   ├── CLAUDE.md               # Global instructions for all projects
│   ├── settings.json           # Model, hooks, permissions, plugins
│   └── statusline-command.sh   # Custom status bar script
├── skills/
│   ├── check/
│   ├── handoff/
│   ├── pr/
│   ├── pr-comments/
│   ├── resolve-conflicts/
│   └── switch/
└── sync.sh                     # Pull live ~/.claude files into this repo
```

## Config

**`CLAUDE.md`** is the instruction file Claude loads at session start. Because it's prompt-cached, anything in here costs almost nothing after the first turn — so it's the right place for rules you'd otherwise repeat every conversation. Mine covers: permissions, code style, token efficiency, plan mode behavior, safety rules, and agent routing with model assignments.

**`settings.json`** controls Claude Code at runtime: the default model (`sonnet`), which tools auto-approve without prompting, hooks, and which plugins are active. Subagents get their model set per-task (`opus` for planning and review, `haiku` for search and exploration).

**`statusline-command.sh`** powers the status bar at the bottom of the terminal. It shows the active model name, a color-coded progress bar for context window usage (green → orange → red), and rate limit usage for the 5-hour and 7-day windows. Turns red at 80% so you know when you're about to hit a wall. 📊

### Hooks

Hooks are automated behaviors wired into `settings.json` that fire without Claude deciding to — the harness runs them directly.

| Event | When | What it does |
|-------|------|-------------|
| `PreToolUse → Bash` | Before any `git commit` | Runs `/check` to catch bugs before they're committed |
| `PostToolUse → AskUserQuestion` | After Claude asks a question | Speaks `"Need your input"` aloud |
| `Stop` | When Claude finishes | Speaks `"Completed..."` aloud |

## Skills

Invoke any of these with `/skill-name` in a Claude Code session.

| Skill | What it does |
|-------|-------------|
| `check` | Reviews staged/unstaged changes for bugs, broken references, and runtime errors. Ignores style. |
| `handoff` | Switches accounts while preserving context, or produces a handoff block to continue in a new session. |
| `pr` | Stages, commits, pushes, and opens a PR — or adds a follow-up comment if one already exists. |
| `pr-comments` | Fetches all PR comments and reviews, summarizes them, and recommends which ones are worth addressing. |
| `resolve-conflicts` | Summarizes merge conflicts, resolves the obvious ones automatically, and asks about the ambiguous ones. |
| `switch` | Switches Claude Code account (logout → login), no context passed. |

## Plugins

Not stored here — the code belongs to the marketplace authors. Install via `/plugins` in Claude Code.

| Plugin | What it provides |
|--------|-----------------|
| `explanatory-output-style` | Adds `★ Insight` blocks for educational output |
| `code-simplifier` | Simplifies recently changed code for clarity |
| `claude-md-management` | Audits and improves CLAUDE.md files |
| `skill-creator` | Create, improve, and benchmark custom skills |
| `commit-commands` | `/commit`, `/commit-push-pr`, `/clean_gone` shortcuts |
| `pr-review-toolkit` | Full PR review suite: `code-reviewer`, `silent-failure-hunter`, `comment-analyzer`, and more |
| `claude-code-setup` | Recommends hooks, agents, and MCP servers for your workflow |
| `context7` | Live library and framework docs via MCP |
| `code-review` | Inline code review command |
| `github` | GitHub MCP — manage issues, PRs, and repos from Claude |
| `playwright` | Browser automation via MCP |
| `superpowers` | Brainstorming, TDD, systematic debugging, git worktrees, and more |

## Keeping in sync

(this is more for me actually) When you change anything in `~/.claude/`, pull it into the repo with:

```bash
./sync.sh
git add -A && git commit -m "sync config" && git push
```

`sync.sh` only touches tracked files — it won't pull in anything unexpected.

## Migrating to a new machine

```bash
cp config/CLAUDE.md ~/.claude/CLAUDE.md
cp config/settings.json ~/.claude/settings.json
cp config/statusline-command.sh ~/.claude/statusline-command.sh && chmod +x ~/.claude/statusline-command.sh
mkdir -p ~/.claude/skills && cp -r skills/* ~/.claude/skills/
```

Plugins aren't included here — reinstall them from the Claude Code marketplace using the list above.
