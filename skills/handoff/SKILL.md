---
name: handoff
description: Switch to a different account while preserving conversation context, or produce a context block to continue in a new session. Use this skill whenever the user says /handoff, "hand off", "running out of tokens", "continue in new session", "pass context", or anything suggesting they need to switch accounts or resume work in a fresh session.
allowed-tools: Bash
---

## Default: same-window handoff

The conversation history stays alive in this window after a logout/login — no context copying needed.

1. Tell the user: "Switching accounts — a browser window will open to authenticate."
2. Run:
   ```bash
   claude auth logout && claude auth login
   ```
3. Confirm the new account is active and continue the conversation.

## If the user explicitly wants to open a new window

Only produce a context block if the user says they want to start fresh or continue in a new terminal.

Synthesize the conversation into these sections (omit any with nothing meaningful):

1. **Goal** — What the user was trying to accomplish (1-2 sentences)
2. **Context** — Repo, branch, key files involved
3. **Decisions made** — Non-obvious choices, trade-offs, rejected alternatives
4. **Work done** — What was completed
5. **Next steps** — What remains, in priority order
6. **Open questions** — Anything unresolved

Output as a single fenced code block:

~~~
```
[HANDOFF CONTEXT]

Goal: <one-line summary>

Context:
- Repo/dir: <working directory or repo name>
- Branch: <branch if relevant>
- Key files: <only directly relevant files>

Decisions made:
- <decision>

Work done:
- <item>

Next steps:
- <item>

Open questions:
- <question if any>

---
Resume from here. You have full context above.
```
~~~

Then tell the user to run `/logout` → `/login`, open a new terminal, and paste the block.

## Tone

Every bullet under 15 words. Be ruthlessly concise.
