---
name: triage
description: Groups code review findings into a prioritized private checklist. Run after /code-review.
allowed-tools: Bash, Read, Grep, Glob, Skill
---

You are turning a pile of review findings into a checklist the user can work through in priority order.

## Input

The findings from the preceding `/code-review` output. Comments fetched by `/pr-comments` work as input too — there, the comment author stands in for the review agent.

If there are no findings in the conversation yet, invoke the `code-review:code-review` skill first, then triage its output. Reuse findings that are already there rather than re-running — a second review costs real time and won't return an identical list, so the checklist would stop matching the review the user just read.

## Output only to the terminal

Never post to GitHub, never comment on a PR, never edit code. This is a private list the user reads before deciding what to raise — it stops being useful the moment it might be published, because a private list can hold half-formed suspicions and a public one can't.

## Grouping

```
P1 - CRITICAL (must fix)
P2 - IMPORTANT (should fix)
P3 - MINOR (nice to fix)
```

Markdown checkboxes, one line each, with `file:line` and which review agent raised it.

**Defaults:** correctness, security, and data integrity are P1. Style, naming, and simplification are P3.

Defaults hold unless there's a specific reason to move something. When you do move an item, state the reason on the line — a naming issue that will cause a real misuse is worth promoting, but the reader needs to see why so they can disagree.

## Whose branch is this

```bash
git config user.email
base=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||')
git log "${base:-main}"..HEAD --format=%ae | sort -u
```

If the base branch can't be detected, check which of `main`/`develop`/`master` exists and say which one you used.

Only ask the user if the result is mixed or empty.

- **Mine** — P3 items are cheap to fix now. Fix them, don't defer.
- **Theirs** — P3 is a non-blocking comment. Never a change request.

The split exists because the cost of a P3 changes with who pays it. On your own branch it's a two-minute edit. On someone else's it's a round trip that spends their attention on something that doesn't matter.

## Close with this line, exactly

```
Private checklist. Verify each item before raising it.
```
