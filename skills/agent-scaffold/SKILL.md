---
name: agent-scaffold
description: Set up a repo for agentic work: project CLAUDE.md, a justfile with verify and a line-count gate, .claude/rules/ and docs/decisions/. Use when the user says /agent-scaffold, "set up this repo", "front-load the context", or starts work in a repo that has no CLAUDE.md.
---

Front-load the context before any code gets generated. Four artifacts, then stop.

Check what already exists first. Never overwrite a file that is there: report it and
show the user what you would have written instead.

## 1. `CLAUDE.md`

Repo-specific facts only. The general standards already load from
`~/.claude/CLAUDE.md` in every session, so repeating them here would be a second copy
that drifts.

If there is no `CLAUDE.md` yet and the repo is too large to hold in one read, invoke
the `init` skill first: it surveys the codebase and writes the file. Then cut what it
wrote down to the shape below, deleting every section that restates
`~/.claude/CLAUDE.md` and every claim not carrying a `file:line`. `/init` writes
paragraphs of style advice that already load in every session; keeping them is the
duplication this skill exists to avoid.

Skip `init` on a small repo, and skip it whenever `CLAUDE.md` already exists: it
rewrites that file, which is the one thing this skill never does.

```markdown
# <repo name>

<One sentence: what this repo does. One more: how to run it.>

## Layout
<Where the entry points, the code, and the tests live in this repo.>

## Commands
<`just verify`, plus any repo-specific command a session cannot guess.>
```

## 2. `justfile`

One verified command per action. This is the thing that stops every session from
improvising its own test invocation.

```
test:
    uv run pytest -q

lint:
    uv run ruff check .

# the 1000-line rule, enforced instead of hoped for
size:
    #!/usr/bin/env bash
    set -euo pipefail
    over=$(find . -name '*.py' -not -path './.venv/*' -not -path './.git/*' -print0 \
      | xargs -0 -r wc -l \
      | awk '$2 != "total" && $1 > 1000 {print $2" ("$1" lines)"}')
    if [ -n "$over" ]; then echo "files over 1000 lines:"; echo "$over"; exit 1; fi

verify: size lint test
```

`size` is the recipe that matters most: it turns the 1000-line cap into something
`just verify` fails on instead of something a markdown file hopes for. Adjust the glob
for the languages the repo actually uses.

Adapt to what the repo actually uses. If it is not a uv project, wire the real
commands and say what you changed. Quiet flags matter: a command that prints 3000
lines has spent the context window on noise.

No `pyproject.toml`, or no test runner in it? Say so and do not write a justfile
that cannot run. `uv run pytest` in a project without pytest fails on a missing
dependency, which looks identical to a broken test and is worse than no command at
all. Set up the project first, or write only the recipes that work today.

Then run `just verify` once and show the output. An untested justfile is a guess.

No `just` on the machine? `brew install just`. Do not silently substitute another
runner: `just verify` is the name every rule and skill refers to.

## 3. `.claude/rules/`

Rules scoped by path, loaded only when the matching files are being worked on. The
shape to copy:

```markdown
---
paths:
  - "**/*.py"
---
<One rule, stated as an instruction, true of these paths and not of every repo.>
```

Then read the repo and propose two or three that are actually true here: a
convention already followed everywhere, a trap someone already fell into, a
directory with different rules from the rest. Propose them, do not write them
unasked.

## 4. `docs/decisions/`

Create the directory with a `README.md` naming the shape:

```markdown
# Decisions

Why things are the way they are. What the code does is in the code.

One file per decision: the decision, why, the alternative rejected, the requirements
it commits to, and `file:line` pointers to where it lives. Never a description of
behaviour.

Written by `/freeze-plan` before any code exists. `/agent-developer` appends what the
build learned and never edits what the plan said; divergence goes under Deviations.
```

## Then stop

Report the four paths and the `just verify` output, including the `size` gate. Do not write code, do not add
dependencies, do not create a src layout nobody asked for.
