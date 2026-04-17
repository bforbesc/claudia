---
name: pr
description: Stage all changes, commit, push, and either open a new PR with a summary comment or add a follow-up comment to an existing PR.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

You are managing a pull request. First detect whether a PR already exists for this branch, then follow the appropriate flow.

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

```
gh pr create --title "<title>" --base develop --body "$(cat <<'EOF'
## What changed
<One plain-English sentence. No jargon. Assume the reader has zero context.>

## Why
<The problem this solves or the goal it achieves. One or two sentences.>

## Key decisions
- <Decision 1: what was chosen and why — written so a non-engineer can understand>
- <Decision 2 if applicable>

## What to review
<What the reviewer should specifically look at. One or two sentences.>
EOF
)"
```

No checklists, no footers, no "Co-Authored-By".

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

Post a comment summarising what changed in this follow-up:

```
gh pr comment <number> --body "$(cat <<'EOF'
<2–4 sentence summary of what was changed in response to review, and any decisions made>
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
