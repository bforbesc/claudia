---
name: pr
description: Stage all changes, commit, push, and either open a new PR with a summary comment or add a follow-up comment to an existing PR.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

You are managing a pull request. First detect whether a PR already exists for this branch, then follow the appropriate flow.

## How to write the PR description (read this first)

Everything you write into a PR body or comment must follow these rules. The goal is text that reads like a thoughtful teammate explaining the change in person — not a machine-generated report.

**Voice**
- Write to a smart colleague who was *not* in the code with you. Lead with the real-world effect, not the code mechanics.
- One idea per sentence. Keep sentences short. Use active voice and present tense.
- Name what actually happens for a user or the system, not the lines you edited. The reviewer can already read the diff — tell them what it *means*.
- Spell out any acronym the first time, except universal ones (API, URL, PR, CI).
- If a section has nothing real to say, write one honest sentence (e.g. "No major trade-offs — this is a straightforward change."). Never pad to fill space.

**Never use these words/phrases** — they are the tell-tale signs of machine-generated text:
> leverage, utilize, facilitate, robust, seamless, comprehensive, enhance, streamline, functionality, in order to, "this PR/commit", "various", "several improvements", "refactored" (without saying what and why)

**Don't** narrate the diff line by line. **Don't** invent "key decisions" that were never real choices.

**One example — the same change, written badly then well:**

❌ Bad (jargon, narrates the diff, no human meaning):
> This PR refactors the authentication handler to leverage a more robust email normalization approach. Implemented `.lower()` invocation on the email field in order to facilitate case-insensitive matching, enhancing overall login functionality.

✅ Good (plain, names the real effect, flags the risk):
> Logins were failing for people whose email had uppercase letters. We now lowercase the email before checking it against the database, so "Bob@x.com" and "bob@x.com" are treated as the same account.
>
> Worth a look: the migration that normalises existing emails — it touches every user row.

## 0. Detect mode

```
gh pr view --json number,url,title 2>/dev/null
```

- If no PR exists → **New PR flow**
- If PR exists → **Follow-up flow**

---

## New PR flow

### 1. Understand the changes

Run in parallel:
```
git status
git diff
git diff --cached
git log --oneline develop..HEAD
```

### 2. Stage files

Stage by name. Avoid `git add -A` / `git add .` unless the user asks. Skip `.env`, secrets, large binaries, unrelated formatting changes.

### 3. Commit

- Imperative mood, 50–72 chars, no period
- No "Co-Authored-By", no mention of Claude or AI
- No "Test plan" sections

```
git commit -m "$(cat <<'EOF'
<message>
EOF
)"
```

### 4. Push and open PR

```
git push -u origin HEAD
```

Write every section using the voice rules above.

```
gh pr create --title "<title>" --base develop --body "$(cat <<'EOF'
## What changed
<One or two sentences in plain English. Say what is now different for a user or the system. Assume the reader has zero context on this branch.>

## Why
<The problem this fixes or the goal it reaches. What was wrong or missing before?>

## Key decisions
- <Only genuine choices where you picked one path over another, and the reason. If there were none, write: "No major trade-offs — straightforward change." Do not invent decisions.>

## What to review
<The one or two spots that most deserve a careful look — risky changes, anything touching shared data, anything you're unsure about. If it's all low-risk, say so.>
EOF
)"
```

No checklists, no footers, no "Co-Authored-By". Re-read your draft once: if any banned word slipped in, or a sentence narrates the diff instead of its meaning, rewrite it.

### 5. Print the PR URL

### 6. Post a plain-English summary in the conversation for the user

After printing the URL, output this block directly in the conversation (not as a PR comment):

```
---
**PR Summary — for you**

**What was done:** <one sentence, plain English, no jargon>
**Key decisions:** <copy exactly from the "Key decisions" section in the PR body above — do not rewrite or paraphrase>
**Impact:** <what this changes or affects in the system>
**What to tell your boss/client:** <one copy-pasteable sentence they can use directly>
**Watch out for:** <any risks, follow-ups, or things that need attention — or "Nothing, this is low risk">
---
```

---

## Follow-up flow

### 1. Understand what changed since the last push

```
git diff
git diff --cached
git log --oneline @{u}..HEAD 2>/dev/null
```

Read any modified files to understand what review feedback was addressed. Only summarise changes from this window.

### 2. Stage and commit

Same rules as above. Commit message should reference what review feedback was addressed if relevant.

### 3. Push

```
git push
```

### 4. Post follow-up comment

Post a comment summarising what changed in this follow-up. Use the voice rules at the top — plain, short, no jargon, name the real effect.

```
gh pr comment <number> --body "$(cat <<'EOF'
<2–4 sentences: what review feedback you addressed and what you changed because of it. Lead with the feedback, then what you did about it. No diff narration.>
EOF
)"
```

### 5. Print the PR URL

### 6. Post a plain-English summary in the conversation for the user

After printing the URL, output this block directly in the conversation:

```
---
**PR Update Summary — for you**

**What changed in this update:** <one sentence, plain English>
**Why:** <what review feedback or issue this addresses>
**What to tell your boss/client:** <one copy-pasteable sentence>
**Watch out for:** <any risks or follow-ups — or "Nothing, this is low risk">
---
```
