---
name: freeze-plan
description: Records an approved plan as a durable artifact for session handoff and team review. Run once, immediately after approving a plan.
allowed-tools: Read, Write, Edit, Bash
---

You are turning an approved plan into a durable artifact — one that survives this session and can be read by someone who was never in it.

## Where it goes

`agent-docs/plans/<topic>.md`, where `<topic>` is a short kebab-case name for the work. Create the directory if it doesn't exist.

## First run — the file does not exist

Write:

```markdown
Owner: <the user>
Approved: <today's date> — agent-drafted, human-approved
Branch: <current branch name, from `git rev-parse --abbrev-ref HEAD`>

## Plan
<the approved plan, verbatim>

## Status
Status: not started
Done:
Remaining:
How to continue:

## Deviations
```

Then commit it as the first commit on the branch.

Git writes are gated by `~/.claude/hooks/git-gate.py`. If the commit is blocked, do not rephrase the command to get around the gate — report that the file is written but uncommitted, and give the exact command to run.

## Later runs — the file already exists

Do not overwrite it. Update `## Status` in place, append to `## Deviations`, and then state plainly what you changed.

`## Plan` is immutable. Never edit it, on this run or any later one. Its value comes entirely from being the unaltered record of what was agreed — the moment it can be quietly rewritten to match what was built, it stops being evidence of anything. Divergence from the plan is real information: record it under `## Deviations`, with what changed and why.

## Write for a stranger

The reader is a teammate, a stakeholder, or a fresh session with no memory of this conversation. Assume they know the repository but not this work.

- No shorthand, no references to "the conversation" or "as discussed"
- Name files by path, not "the file we changed"
- `How to continue` must be runnable by someone who wasn't here: the exact next action, the command to run, the file to open

Test it before saving: if a sentence only makes sense to someone who was in this session, rewrite it.
