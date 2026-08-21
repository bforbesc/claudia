---
name: freeze-plan
description: Store the plan this conversation produced to docs/decisions/<topic>.md, stamped with the commit it was written against, as the specification /agent-developer builds from. Use when the user says /freeze-plan or is comfortable with a plan and wants it locked before code.
allowed-tools: Read, Grep, Glob, Bash, Write
---

You store the plan this conversation produced. That is the whole job.

The plan was written by the planner and argued over by the user. The pushback already
happened. Do not re-check it, do not improve it, do not add a requirement it does not
have. A plan you edited on the way in is a plan nobody agreed to.

If the plan is missing a section, say which and stop. That is the user's to fill.

## 1. Write it

`docs/decisions/<topic>.md`. If a file is already there, do not overwrite it: report
it and show what you would have written.

```markdown
# <the decision>
Owner: <the user>. Date: <today>. Branch: <git rev-parse --abbrev-ref HEAD>.
Frozen at: <git rev-parse HEAD>.

## Decision
One or two sentences.

## Why
The constraint that forced it. The alternative rejected, and what it cost.

## Requirements
- R1 — <one falsifiable behaviour> — `tests/test_thing.py::test_the_behaviour`

## Design
<interfaces and boundaries, each decision citing the R-ids it closes>

## Tasks
1. <one red-green slice: write the test, see it fail, then the minimum code> — closes R1

## Planned files
- `path/to/file.py` — what it will hold, and whether it exists today
```

Requirements, Design and Tasks come from the plan as it stands. Decision and Why come
from the conversation: the framing agreed before the planner ran, one or two sentences
each. Planned files is the file list the plan implies, and if the plan does not imply
one, say so rather than inventing it.

`Frozen at` is the commit the plan was written against, and the only machine-checkable
part of this file. `/agent-developer` compares it to `HEAD` and refuses to build
against a moved tree.

## 2. What frozen means

Nothing above is rewritten. `/agent-developer` appends what the build learned:
`## Where it lives` with `file:line` per R-id, `## Risks accepted`, `## Deviations`.

The gap between what this file planned and what the build appended is the record worth
keeping, and it disappears the moment someone edits the plan to match the code. A plan
that turns out to be wrong is not edited: the build records it under Deviations, or the
work stops and this file gets `## Abandoned` with the reason.

This is the only file the workflow writes, and it exists because `/review-pr` runs in a
fresh session with no memory of the build. Without it, nothing can check whether the
code did what was promised.

There is no `docs/plans/`. Three places hold truth: this file for why, `.claude/rules/`
for what must be enforced, and the code and tests for what the system does.

## Then stop

Report the path and the `Frozen at` commit. Do not write tests, do not write code, do
not open a PR. The next step is `/agent-developer <topic>`.
