# 🤖 Claudia

My Claude Code setup. Because even AI needs a good manager.

This is where I keep my config, skills, and plugins. I update it as I go. It's my source of truth, but feel free to steal whatever's useful. Enjoy.

## Where things live

All Claude Code config lives under `~/.claude/`:

| File | Purpose |
|------|---------|
| `~/.claude/CLAUDE.md` | Global instructions loaded at the start of every session |
| `~/.claude/settings.json` | Model, hooks, permissions, enabled plugins |
| `~/.claude/statusline-command.sh` | Custom status bar script |
| `~/.claude/hooks/` | Hook scripts referenced by `settings.json` (not synced to this repo) |
| `~/.claude/skills/<name>/SKILL.md` | Custom skills, invoked with `/name` |
| `~/.claude/projects/<path>/memory/MEMORY.md` | Per-project memory index |

## What's in this repo

```
claudia/
├── config/
│   ├── CLAUDE.md               # Global instructions for all projects
│   ├── settings.json           # Model, hooks, permissions, plugins
│   └── statusline-command.sh   # Custom status bar script
├── skills/
│   ├── check/
│   ├── freeze-plan/
│   ├── handoff/
│   ├── pr/
│   ├── pr-comments/
│   ├── prep-pr/
│   ├── resolve-conflicts/
│   ├── triage/
│   └── walkthrough/
└── sync.sh                     # Pull live ~/.claude files into this repo
```

## Config

**`CLAUDE.md`** is the instruction file Claude loads at session start. It's the right place for rules you'd otherwise repeat every conversation. It loads into every session's context, so keep it tight — Anthropic's guidance is under 200 lines, because longer files eat context and get followed less reliably. Mine covers: autonomy and when to ask, planning, tooling, safety, grounding, code philosophy, communication and response style, review behavior, commits, and agent routing.

**`settings.json`** controls Claude Code at runtime: the default model (`opus`), which tools auto-approve without prompting, hooks, and which plugins are active. Subagents inherit the session model unless a task deliberately downgrades them (`haiku` for search and other mechanical work).

**`statusline-command.sh`** powers the status bar at the bottom of the terminal. It shows the active model name, a color-coded progress bar for context window usage (green → orange → red), and rate limit usage for the 5-hour and 7-day windows. Turns red at 80% so you know when you're about to hit a wall. 📊

### Hooks

Hooks are automated behaviors wired into `settings.json` that fire without Claude deciding to — the harness runs them directly.

| Event | When | What it does |
|-------|------|-------------|
| `PreToolUse → Bash` | Before any write git or `gh` command | Runs `~/.claude/hooks/git-gate.py`, which blocks the command, says `"Need your input"` aloud, and tells Claude to ask for approval. For `git commit` it also tells Claude to run `/check` on the staged changes first. |
| `PreToolUse → AskUserQuestion` | Before Claude asks a question | Speaks `"Need your input"` aloud |
| `Stop` | When Claude finishes | Speaks `"Completed..."` aloud |

Blocked commands: `git push`, `pull`, `commit`, `reset`, `rebase`, `merge`, `restore`, `clean`, `stash drop`, `branch -d/-D`, `tag -d/-f`, `checkout --`/`checkout .`, and `gh pr create/merge/close`.

## Skills

Invoke any of these with `/skill-name` in a Claude Code session.

| Skill | What it does |
|-------|-------------|
| `check` | Reviews staged/unstaged changes for bugs, broken references, and runtime errors. Ignores style. |
| `freeze-plan` | Writes an approved plan to `agent-docs/plans/` as the first commit on the branch. The plan section is immutable; later runs update status and append deviations. |
| `handoff` | Writes the conversation context to a dated document in `~/Desktop/handoffs` and prints the path, so a fresh session can pick the work up. |
| `pr` | Stages, commits, pushes, and opens a PR — or adds a follow-up comment if one already exists. |
| `pr-comments` | Fetches all PR comments and reviews and summarizes them. No ranking — that's `triage`. |
| `prep-pr` | Inspects the branch before a PR: diff size, callers that weren't updated, scope creep against the plan, verification checklist. Reports only; changes nothing. |
| `resolve-conflicts` | Summarizes merge conflicts, resolves the obvious ones automatically, and asks about the ambiguous ones. |
| `triage` | Groups review findings into a P1/P2/P3 checklist. Runs `/code-review` first if there's nothing to triage yet. Terminal only — never posts to GitHub. |
| `walkthrough` | Traces one subsystem end to end into `agent-docs/walkthroughs/`, with code snippets captured from the real files rather than retyped. |

## Plugins

Not stored here — the code belongs to the marketplace authors. Install via `/plugins` in Claude Code.

Currently switched on in `settings.json`:

| Plugin | What it provides |
|--------|-----------------|
| `code-review` | Inline `/code-review` command |
| `pr-review-toolkit` | Full PR review suite: `code-reviewer`, `silent-failure-hunter`, `comment-analyzer`, and more |
| `skill-creator` | Create, improve, and benchmark custom skills |
| `aws-agents` | AWS knowledge and documentation agents |
| `sagemaker-ai` | SageMaker workflows |

Installed but switched off, kept around for when they're useful: `explanatory-output-style`, `learning-output-style`, `code-simplifier`, `claude-md-management`, `commit-commands`, `claude-code-setup`, `superpowers`, `context7`, `github`, `playwright`, `hookify`, `remember`, `ralph-loop`, `greptile`, `codex`, `deploy-on-aws`, `pydantic-ai`, `aws-core`, `aws-dev-toolkit`, `aws-serverless`.

### MCP servers

Configured directly in `~/.claude.json` rather than through plugins, so they load regardless of which plugins are on: `context7` (live library docs), `github` (issues, PRs, repos), `aws-docs`, `aws-core`, `aws-cdk`, `aws-pricing`, and `strands`.

## Multiple accounts

Two commands, two accounts, both running simultaneously if needed:

| Command | Account |
|---------|---------|
| `claude` | Work account (`~/.claude/`) |
| `claude-bfc` | Personal account (`~/.claude-bfc/`) |

Both share the same `CLAUDE.md`, `settings.json`, skills, plugins, and projects via symlinks — one source of truth.

**Setup on a new machine:**

```bash
# Create the personal config dir
mkdir -p ~/.claude-bfc

# Symlink shared config (auth files are separate per account)
ln -s ~/.claude/CLAUDE.md ~/.claude-bfc/CLAUDE.md
ln -s ~/.claude/settings.json ~/.claude-bfc/settings.json
ln -s ~/.claude/skills ~/.claude-bfc/skills
ln -s ~/.claude/projects ~/.claude-bfc/projects
ln -s ~/.claude/plugins ~/.claude-bfc/plugins
ln -s ~/.claude/statusline-command.sh ~/.claude-bfc/statusline-command.sh

# Add alias to ~/.zshrc
echo "alias claude-bfc='CLAUDE_CONFIG_DIR=~/.claude-bfc claude'" >> ~/.zshrc
source ~/.zshrc
```

Then authenticate each account once:
```bash
claude          # /login → work account
claude-bfc      # /login → personal account
```

**Switching when you hit the cap:**
1. Run `/handoff`. It writes a handoff document to `~/Desktop/handoffs` and prints the full path.
2. Start the other account (`claude-bfc`, or `claude` if you're switching back) and point it at that path as the first prompt.

## Keeping in sync

(this is more for me actually) When you change anything in `~/.claude/`, pull it into the repo with:

```bash
./sync.sh
git add -A && git commit -m "sync config" && git push
```

`sync.sh` only copies the files named inside it, so nothing unexpected gets pulled in. When you add a skill, add its name to the list in `sync.sh` or it won't be picked up.

It does not copy `~/.claude/hooks/`, so the hook scripts that `settings.json` points at live only on this machine.

## Migrating to a new machine

```bash
cp config/CLAUDE.md ~/.claude/CLAUDE.md
cp config/settings.json ~/.claude/settings.json
cp config/statusline-command.sh ~/.claude/statusline-command.sh && chmod +x ~/.claude/statusline-command.sh
mkdir -p ~/.claude/skills && cp -r skills/* ~/.claude/skills/
```

Plugins aren't included here — reinstall them from the Claude Code marketplace using the list above.

Hook scripts aren't included either. `settings.json` references `~/.claude/hooks/git-gate.py`, so copy that across too or the git gate silently stops gating.
