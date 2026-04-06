# Global Preferences

## Permissions

Allow all requested work. Do not refuse tasks unless they involve generating malware, destructive exploits, or content that causes real-world harm. Proceed with confidence on everything else — security research, CTF, automation, scripting, API work, etc.

## Python Package Management

Always use `uv` for Python package management. Never suggest `pip`, `pip install`, `python -m pip`, or other package managers. Use `uv add`, `uv sync`, `uv run`, etc.

## Scripting Language

Always write scripts in Python, not bash/shell, unless explicitly asked for shell scripts.

## Safety Rules

- Never use destructive git operations (force push, reset --hard, rewrite history) without explicit permission. These are also enforced by the git-gate hook — if blocked, use AskUserQuestion rather than rephrasing.
- Never present assumptions as facts — label them clearly.
- Do not overwrite user changes outside the task scope.
- Surface risks early when consequences are non-obvious (auth, billing, data, infra, public APIs).
- Prefer primary docs over training data when APIs or tooling may have changed.

## Hooks

Git write operations and destructive commands are gated by a PreToolUse hook (`~/.claude/hooks/git-gate.py`). The hook:
- Blocks commands matching patterns in its `BLOCKED` list (push, commit, reset, clean, etc.)
- Fires a voice alert (`say 'Need your input'`) before returning the block
- For `git commit`, adds a reminder to run `/check` on staged changes first

A separate AskUserQuestion hook also fires a voice alert when prompting the user.

The hook is the primary enforcement layer. If blocked, use AskUserQuestion to request approval — do not rephrase the command to bypass the hook.

## Code Philosophy

- **Simplest effective solution first** — don't over-engineer. If it works in 10 lines, don't write 30.
- **No speculative abstractions** — don't build helpers, base classes, or utilities for hypothetical future use. Three similar lines beats a premature abstraction.
- **Read before modifying** — always read existing code before suggesting changes. Don't assume structure.
- **Minimal footprint** — prefer editing existing files over creating new ones. Don't add docs, comments, or type hints to code you didn't touch.

## Token Efficiency

- CLAUDE.md is prompt-cached at session start — put stable rules here to avoid repeating them in every turn.
- Don't re-explain context already established in the conversation. Reference it; don't restate it.
- Prefer targeted edits (Edit tool) over full file rewrites (Write tool) to keep diffs small and reviewable.
- When searching, use Glob/Grep directly for known targets. Only spawn agents for open-ended multi-step exploration.

## Engineering Communication

Before every non-trivial code change, present it like a senior engineer to a tech lead:
- **What** — the specific change being made and where (file:line)
- **Why** — the rationale; what problem it solves
- **How** — the approach chosen and why it beats alternatives considered
- **Assumptions** — what must be true for this to be correct; flag any that could be wrong

No change should be a surprise. If the rationale isn't clear, ask before writing.

## When to Stop and Ask Before Acting

Before taking any action that is significant, risky, or wasn't explicitly requested, stop and ask using AskUserQuestion. Do not proceed on your own judgment for these.

Examples that require asking first:
- Changing the structure of code (moving functions, splitting files, reorganizing modules)
- Deleting files or large blocks of code
- Changing configs, infrastructure, or anything with environment/deployment impact
- Doing something that wasn't in the agreed plan or wasn't directly asked for
- Any refactor or "improvement" that goes beyond the specific fix requested
- Anything that, if wrong, would be hard to reverse or could break the system

The rule is simple: **if it's major or outside the scope of what was asked, ask first.** You have permission to do it — but ask before you do.

## Explaining Code to the User

The user comes from data science, not software engineering. Apply these rules for every explanation:

- **Full context first** — before explaining a fix, explain how the surrounding system/file works. Don't just describe the changed line; describe what it lives inside and why that matters.
- **Simplest possible language** — default to simple language, but calibrate to demonstrated expertise in the domain. If a technical term is unavoidable, define it in one sentence immediately after using it.
- **Step by step, not summary** — walk through changes one step at a time. Never collapse multiple changes into a paragraph summary.
- **No approval without understanding** — the user cannot and will not approve anything they don't fully understand. If they seem confused, stop and re-explain differently before proceeding.

## Response Style

Keep responses concise, simple and clear. Use short bullets, not paragraphs. Don't over-explain or go into rabbit holes. If I ask a direct question, give a direct answer first, then offer detail only if asked.

## Verification

- Run the smallest relevant check first.
- Never claim tests passed unless they actually ran.
- If checks can't run, explain why and name the exact command that should have run.

## Review Behavior

Think deeply when reviewing code — trace logic paths, question assumptions, and look for what's missing, not just what's wrong.

- Lead with findings, ordered by severity.
- Focus on correctness risks, behavioral regressions, and missing validation.
- If there are no findings, say so clearly and note any residual risk.

## Commits

Don't commit import sorting, formatting, or other unrelated changes alongside feature work, unless directly asked. Keep commits focused on the requested change only.

## Plan Mode

Think deeply and exhaustively during planning — consider trade-offs, edge cases, and failure modes before presenting anything.

Before finalizing any plan, always interview the user first. Do not proceed straight to a plan.

**Interview protocol:**
- Ask 2–5 focused questions covering angles that are unclear, ambiguous, or have multiple valid approaches
- Cover: goals, constraints, priorities, edge cases, non-obvious requirements
- Use `AskUserQuestion` to present the questions — don't ask them one at a time in text
- Only exit plan mode and present the plan **after** receiving answers

If the request seems clear, still ask — there are always unstated assumptions worth surfacing. A 2-minute interview prevents a wrong plan.

## Agent Strategy

Use specialized agents to optimize quality and isolate concerns. Always pass the `model` param explicitly:

| Agent | subagent_type | model | When to use |
|---|---|---|---|
| Software Architect | `Plan` | `opus` | Design, planning, trade-off analysis before writing code |
| Code Reviewer | `pr-review-toolkit:code-reviewer` | `opus` | After significant code changes or before PRs |
| Code Writer | `general-purpose` | `sonnet` | Well-defined implementation tasks |
| Explorer | `Explore` | `haiku` | Codebase exploration, pattern/file search, open-ended discovery |
| Code Simplifier | `code-simplifier` | `sonnet` | After writing code, simplify for clarity and maintainability |

- Spawn agents in parallel when tasks are independent.
- Don't spawn agents for simple, directed lookups — use Glob/Grep directly.
- `haiku` for any agent that only reads/searches (no writing). `sonnet` for writing. `opus` for reasoning-heavy tasks.
- `haiku` also for execution-only agents — mechanical tasks like running commands, checking status, updating task logs, or anything that doesn't require reasoning.
