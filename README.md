# 🤖 Claudia

My Claude Code setup. Because even AI needs a good manager.

This is where I keep my config, skills, and plugins. I update it as I go. It's my source of truth, but feel free to steal whatever's useful. Enjoy.

## The workflow these skills are for

The skills are a chain, not a menu. Each one hands the next a specific artifact, and out of order most of them have nothing to read.

```
0. Discovery       /walkthrough if the code is unfamiliar, then plan in conversation
                   and argue with it until it holds
   Freeze          /freeze-plan  →  docs/decisions/<topic>.md
1. Build           /agent-scaffold once per repo, then /agent-developer <topic>
                   /open-pr
2. Review          /review-pr, in a fresh session
   Upkeep          /pay-tech-debt, whenever the pace has left a mess
```

The plan file is the load-bearing part. `/freeze-plan` writes it before any code, with one falsifiable requirement per R-id and the test name that will prove each one. `/agent-developer` builds against it and appends where each requirement landed. `/review-pr` then checks the code against a specification it had no hand in writing. Nothing rewrites the plan, so the gap between what was promised and what was built stays visible.

Three places hold truth and there is never a fourth: the code and tests for what the system does, `.claude/rules/*.md` for what must be enforced, `docs/decisions/` for why. No plans directory, no walkthrough directory, no agent-facing docs.

## Where things live

All Claude Code config lives under `~/.claude/`:

| File | Purpose |
|------|---------|
| `~/.claude/CLAUDE.md` | Global instructions loaded at the start of every session |
| `~/.claude/settings.json` | Model, hooks, permissions, enabled plugins |
| `~/.claude/statusline-command.sh` | Custom status bar script |
| `~/.claude/hooks/` | Hook scripts referenced by `settings.json` |
| `~/.claude/agents/<Name>.md` | Custom subagent definitions |
| `~/.claude/skills/<name>/SKILL.md` | Custom skills, invoked with `/name` |
| `~/.claude/projects/<path>/memory/MEMORY.md` | Per-project memory index (not published here) |

## What's in this repo

```
claudia/
├── config/
│   ├── CLAUDE.md               # Global instructions for all projects
│   ├── settings.json           # Model, hooks, permissions, plugins
│   └── statusline-command.sh   # Custom status bar script
├── hooks/
│   └── git-gate.py             # Approve/deny prompt before any git write
├── agents/                     # Seven subagents, one job each
│   ├── Explore.md
│   ├── code-reviewer.md
│   ├── comment-analyzer.md
│   ├── implementer.md
│   ├── security-scanner.md
│   ├── silent-failure-hunter.md
│   └── test-writer.md
├── skills/
│   ├── agent-developer/
│   ├── agent-scaffold/
│   ├── freeze-plan/
│   ├── handoff/
│   ├── humanizer/
│   ├── open-pr/
│   ├── pay-tech-debt/
│   ├── resolve-pr-conflicts/
│   ├── review-pr/
│   └── walkthrough/
└── sync.sh                     # Pull the named ~/.claude files into this repo
```

## Config

**`CLAUDE.md`** is the instruction file Claude loads at session start. It's the right place for rules you'd otherwise repeat every conversation. It loads into every session's context, so keep it tight — Anthropic's guidance is under 200 lines, because longer files eat context and get followed less reliably. Mine is 40 lines: the Zen of Python as the code philosophy, a 1000-line cap per file, tests first, where truth lives, what to ask about before doing, and how to write.

**`settings.json`** controls Claude Code at runtime: the default model (`opus`), effort level, which tools auto-approve without prompting, hooks, and which plugins are active. Subagents don't inherit any of that — every agent file pins its own `model` and `effort`, so a session on Opus still runs the mechanical work on Sonnet or Haiku.

**`statusline-command.sh`** powers the status bar at the bottom of the terminal. It shows the active model name, a color-coded progress bar for context window usage (green → orange → red), and rate limit usage for the 5-hour and 7-day windows. Turns red at 80% so you know when you're about to hit a wall.

### Hooks

Hooks are automated behaviors wired into `settings.json` that fire without Claude deciding to — the harness runs them directly.

| Event | When | What it does |
|-------|------|-------------|
| `PreToolUse → Bash` | Before any write git or `gh` command | Runs `hooks/git-gate.py`, which returns `permissionDecision: "ask"` so you get an approve/deny prompt. Read-only git commands pass through untouched. |
| `PreToolUse → AskUserQuestion` | Before Claude asks a question | Speaks `"Need your input"` aloud |
| `Stop` | When Claude finishes | Speaks `"Completed..."` aloud |

Blocked commands: `git push`, `pull`, `commit`, `reset`, `rebase`, `merge`, `restore`, `clean`, `stash drop`, `branch -d/-D`, `tag -d/-f`, `checkout --`/`checkout .`, and `gh pr create/merge/close`.

## Skills

Invoke any of these with `/skill-name` in a Claude Code session.

| Skill | What it does |
|-------|-------------|
| `walkthrough` | Traces a scoped part of the codebase end to end, in the conversation. Writes no file: line-numbered snippets of code you're about to edit rot immediately, and re-running this costs less than reading a stale copy. |
| `freeze-plan` | Stores the plan the conversation produced to `docs/decisions/<topic>.md`, stamped with the commit it was written against. It stores and does not validate — the argument already happened. |
| `agent-scaffold` | Sets a repo up for agentic work: project `CLAUDE.md`, a `justfile` with `verify`, a line-count gate, `.claude/rules/` and `docs/decisions/`. Run it once per repo before anything else. |
| `agent-developer` | Builds a frozen plan through a fixed chain: write the tests, watch them fail for the right reason, implement, verify, scan, review, then append where each requirement landed. Never edits the plan. |
| `open-pr` | Opens a PR for the current branch, or takes in an existing one's review comments and answers them one thread at a time. Inspects the branch first and stops for you to decide. |
| `review-pr` | Reviews a PR as a principal engineer with four specialist subagents, from a PR number, link, or the branch you cloned. Reports in the terminal; posts only the findings you name. |
| `pay-tech-debt` | Measures debt in a scope you name — a path, a PR, a commit range, a subsystem — then pays one item with the tests green on both sides and no behaviour change. |
| `resolve-pr-conflicts` | Summarizes merge conflicts, resolves the obvious ones automatically, and asks about the ambiguous ones. |
| `handoff` | Writes the conversation context to a dated document in `~/Desktop/handoffs` and prints the path, so a fresh session can pick the work up. |
| `humanizer` | Rewrites text that reads as machine-generated, based on Wikipedia's "Signs of AI writing." Third-party, MIT licensed. `open-pr` and `review-pr` both run their drafts through it before anything reaches GitHub, so it isn't optional. |

Two skills in my live config are deliberately absent here: one carries an employer's take-home challenge and its grading rubric, the other describes where a specific client engagement's context lives. `sync.sh` names both and says why, so a future sync doesn't quietly pick them up.

## Subagents

Seven agents, one job each. Skills name them in backticks rather than describing what they want, so routing is deterministic and never depends on a description matching.

| Agent | Model | Job |
|-------|-------|-----|
| `test-writer` | sonnet, max | Writes tests before any implementation exists. Never writes implementation. |
| `implementer` | sonnet, max | Writes the minimum code that makes existing failing tests pass. Never edits a test. |
| `code-reviewer` | sonnet, high | Read-only review for bugs and for the rules in `CLAUDE.md`. |
| `silent-failure-hunter` | sonnet, medium | Swallowed errors, empty catch blocks, fallbacks that hide a failure. |
| `security-scanner` | sonnet, medium | Secrets, injection, authorization, data exposure. |
| `comment-analyzer` | sonnet, medium | Whether comments and `docs/decisions/` entries still match the code they point at. |
| `Explore` | haiku | Read-only search across many files when only the conclusion is needed. |

Each one resolves its own scope explicitly, because a subagent starts with an empty context and a git-status snapshot from the parent session. Handed a PR, it runs the exact `gh pr diff <number> -R <repo>` command it was given; handed nothing, it reads the working tree and says so. An empty diff is reported as an empty diff, never as a clean pass.

## Plugins

Not stored here — the code belongs to the marketplace authors. Install via `/plugins` in Claude Code.

All of them are currently switched off. `pr-review-toolkit` used to supply `code-reviewer`, `silent-failure-hunter` and `comment-analyzer`; those three now live in `agents/` as local copies rewritten to match the rest of the setup, so the plugin came off. The rest are installed and kept around for when they're useful: `explanatory-output-style`, `learning-output-style`, `code-simplifier`, `claude-md-management`, `commit-commands`, `skill-creator`, `code-review`, `claude-code-setup`, `superpowers`, `context7`, `github`, `playwright`, `hookify`, `remember`, `ralph-loop`, `greptile`, `codex`, `deploy-on-aws`, `pydantic-ai`, `aws-core`, `aws-agents`, `sagemaker-ai`, `aws-serverless`.

### MCP servers

Configured directly in `~/.claude.json` rather than through plugins, so they don't depend on which plugins are on. Connecting: `context7` (live library docs), `github` (issues, PRs, repos), `aws-docs`, `aws-pricing`, `strands`. Configured but currently failing to connect: `aws-core`, `aws-cdk`. Check with `claude mcp list`.

## Local model

`claude-local` (a `~/.zshrc` function, not stored here) runs Claude Code against a
model served locally by Ollama (`qwen3.5:35b-mlx`, Apple's MLX engine) instead of the
Anthropic API. It auto-starts Ollama if it isn't running and pre-warms the model
before handing off to `claude`.

It points `CLAUDE_CONFIG_DIR` at `~/.claude-local/`, which symlinks `CLAUDE.md`,
`skills/`, and `statusline-command.sh` back to `~/.claude/` so both configs share one
source of truth, with its own `settings.json` (dark theme, low effort — the local
model is slower) and its own `plugins/` and `projects/`.

## Keeping in sync

(this is more for me actually) When you change anything in `~/.claude/`, pull it into the repo with:

```bash
./sync.sh
git add -A && git commit -m "sync config" && git push
```

`sync.sh` copies only the skills, hooks and agents named in the lists at the top of the file, so a new skill stays private until you add it. It also prints anything still tracked here that no longer exists in `~/.claude`, because copying never deletes and a renamed skill would otherwise live on as a file nothing produced. It reports those rather than pruning: removing a file from the repo is a decision, not a side effect of a sync.

Not published, on purpose: `~/.claude/projects/*/memory/` and `settings.local.json`.

## Migrating to a new machine

```bash
cp config/CLAUDE.md ~/.claude/CLAUDE.md
cp config/settings.json ~/.claude/settings.json
cp config/statusline-command.sh ~/.claude/statusline-command.sh && chmod +x ~/.claude/statusline-command.sh
mkdir -p ~/.claude/skills && cp -r skills/* ~/.claude/skills/
mkdir -p ~/.claude/hooks && cp hooks/* ~/.claude/hooks/
mkdir -p ~/.claude/agents && cp agents/* ~/.claude/agents/
```

Plugins aren't included here — reinstall them from the Claude Code marketplace using the list above.

A new `~/.claude/agents/` directory isn't detected by a running session, so restart Claude Code after that last line.
