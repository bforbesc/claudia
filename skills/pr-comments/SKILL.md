---
name: pr-comments
description: Fetch and summarize all comments and reviews on the current pull request.
allowed-tools: Bash, Read, Grep, Glob
---

You are collecting comments on a pull request. Fetch them all and summarize what each one says.

Don't rank them, don't judge whether they're worth addressing, and don't recommend what to act on. Prioritizing is `/triage`'s job — run it on this output when the user wants a worked checklist. Keeping collection separate from judgement means the user sees the full picture before anything gets filtered out.

## 1. Find the PR

```
gh pr view --json number,url,title 2>/dev/null
```

If no PR exists for this branch, say so and stop.

## 2. Fetch all comments and reviews

Run in parallel:

```
gh pr view <number> --json comments,reviews,reviewDecision
gh api repos/{owner}/{repo}/pulls/<number>/comments
```

## 3. Produce summary

For each comment or review thread:

- **Author**: who left it
- **Where**: `file:line` for inline comments, or "top-level" for PR-wide ones
- **Comment**: one-line summary of what they said

Preserve every comment. Don't merge near-duplicates or drop nitpicks — a comment that looks trivial to you may be the one the user cares about, and this output is the raw material for whatever comes next.

### Output format

Group by thread, in the order they were left.

**PR #<number> — Comments (N total)**

- @author — `file:line` — "<summary>"

Note the current `reviewDecision` at the end (approved, changes requested, or pending).

## 4. Stop there

Present the summary and stop. Don't make changes. If the user wants these prioritized into a checklist, point them at `/triage`.
