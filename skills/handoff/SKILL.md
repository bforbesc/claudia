---
name: handoff
description: Summarise the current conversation into a handoff document saved to ~/Desktop/handoffs, so a fresh agent can pick up the work later. Use when the user says /handoff, "hand off", "running out of tokens", "continue in new session", or "pass context".
disable-model-invocation: true
allowed-tools: Bash, Write, Read
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

## Where to save

Save to `~/Desktop/handoffs/`. Create the folder first if it doesn't exist:

```bash
mkdir -p ~/Desktop/handoffs
```

Filename: `handoff-$(date +%Y-%m-%d-%H%M)-<short-slug>.md`, where `<short-slug>` is a 2-4 word kebab-case summary of the goal.

After saving, print the full file path so the user can point the next agent to it.

## What to include

Synthesise from the conversation. Omit any section that is empty — don't pad.

- **Goal** — 1-2 sentences on what we're trying to achieve.
- **Context** — repo, branch, key files (by path).
- **Decisions made** — what was chosen and why.
- **Work done** — what's already complete.
- **Next steps** — what the next session should do.
- **Open questions** — anything unresolved.
- **Suggested skills** — skills the next agent should invoke (e.g. `/grilling`, `/open-pr`).

## Rules

- Don't duplicate content already in other artifacts (plans, PRDs, ADRs, issues, commits, diffs). Reference them by path or URL instead.
- Redact secrets: API keys, passwords, tokens, PII.
- If the user passed an argument, treat it as the next session's focus and tailor the doc to it.

## Tone

Every bullet under 15 words. Ruthlessly concise.