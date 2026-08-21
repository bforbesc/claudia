---
name: open-pr
description: Open a pull request, or update one that already exists by taking in its review comments and answering them. Use when the user says /open-pr, "open a PR", "push this", "address the PR comments", "what did the reviewers say", or pastes review feedback to act on.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, Skill
---

You are managing a pull request. First detect whether a PR already exists for this branch, then follow the appropriate flow.

This skill always acts on the branch or worktree you are in, never on a PR named by
number or link. So every `gh pr` call here stays bare and every `gh api` call keeps
its `{owner}/{repo}` placeholders: both resolve from the current directory, which is
the right answer here and the wrong one in `/review-pr`. Do not copy that skill's
`-R <repo>` pattern into this one. If you are being asked about a PR that is not this
branch, this is the wrong skill.

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
> Worth a look: the migration that normalises existing emails because it touches every user row.

## Humanize before you post

Nothing reaches GitHub on its first draft. Before every write, run the drafted text
through the `humanizer` skill in embedded mode, which returns the final text and
nothing else. That covers the PR title and body, the commit message, each inline
reply, and the round-up comment.

Draft, humanize, then post. Humanizing after `gh pr create` is too late, because the
first version is the one reviewers get notified about.

Three carve-outs, because the templates below deliberately break humanizer rules:

- The fixed section headings (`## What changed`, `## Why`, and so on) stay as written.
  Humanize the prose under them.
- The bold labels stay, in the round-up comment and in the user-summary blocks.
  Humanizer §15 and §16 flag bold mini-heading lists, but here they are a scannable
  form the reader relies on, not decoration.
- Humanizer §30 says do not write about the previous version. A PR description is a
  document about a change, which §30 exempts. Keep the "Why" section's account of what
  was wrong before.

Everything else applies, including the em dash rule in §14.

## Pre-flight (run first, always)

Inspect the branch before anything is staged. Every finding traces to a command you
actually ran, and you show the command and its output, not a paraphrase.

**Base branch.** Do not hardcode `main`; this user's repos also use `develop`, and
there is no safe default between them.

A PR already states its base, so ask it first. This is the only answer that is not a
guess, and in the Follow-up flow it is always available:

```
gh pr view --json baseRefName -q .baseRefName
```

No PR yet, so nothing empty here is an error. Then, and only then, detect:

```
git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||'
git branch -r --format='%(refname:short)' | grep -E 'origin/(develop|main|master)$'
```

If the first prints nothing, `origin/HEAD` is unset. Pick from what the second lists,
say which you used, and never fall back silently. A wrong base gives a wrong commit
range, and every check below reads that range.

Then write that name literally everywhere below, in place of `<base>`. Each Bash
call runs in a fresh shell, so a variable set in this step is gone by the next one.

**Diff size.** `git diff <base>...HEAD --stat`. Over 200 lines, propose concrete
commit boundaries: name the actual files and the specific commit each group becomes,
in order. "This should be split" without the split is not advice anyone can act on.

**Callers.** List every function, class or constant whose signature or behaviour
changed. For each, grep the repo for callers and report which callers are *not* in
this diff. Those kept the old expectations. Never assemble a caller list by reading
files: reading finds what you looked for, grep finds what is there, and a missed
caller is exactly the failure this check exists to prevent.

**What no type checker catches.** Return types that changed shape, new exceptions
raised, changed default arguments, renamed dictionary or config keys.

**Bugs that will actually break.** Off-by-one, wrong variable, missing return,
inverted condition, wrong column or key name, silent data loss from a join,
None access, unclosed resource, injection, secrets in code. Ignore style, naming,
docstrings, import order and refactoring opportunities that fix no bug.

**Scope creep.** Read `docs/decisions/` for the entry naming this branch. Its
`## Planned files` section was written before the code existed, so compare the diff's
file list against it by name. A file in the diff and not in that section is the first
place scope creep shows up.

Then list anything in the diff nobody asked for: new docstrings, defensive
`try`/`except`, extra helpers, generated comments. Delete those before staging.
Then note where the implementation diverged from the decision, which is information
the reviewer wants.

No entry for this branch, or no `## Planned files` section? Say so. It means nothing
recorded the intent before the code, and this check cannot run.

Report all of it, then stop and let the user decide before you stage anything.

---

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
git log --oneline <base>..HEAD
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
gh pr create --title "<title>" --base <base> --body "$(cat <<'EOF'
## What changed
<One or two sentences in plain English. Say what is now different for a user or the system. Assume the reader has zero context on this branch.>

## Why
<The problem this fixes or the goal it reaches. What was wrong or missing before?>

## Key decisions
- <Only genuine choices where you picked one path over another, and the reason. If there were none, write: "No major trade-offs — straightforward change." Do not invent decisions.>

## What to review
<The one or two spots that most deserve a careful look — risky changes, anything touching shared data, anything you're unsure about. If it's all low-risk, say so.>

## Evidence
<What you ran, and what it produced. Whatever form the proof took: a test command and its output, a curl response, a log line, a screenshot of clicking through it. Paste the real thing, never a description of it from memory. Then name what nobody checked and what breaks if it turns out wrong. If you ran nothing, say that plainly.>
EOF
)"
```

No checklists, no footers, no "Co-Authored-By". Draft the title, body and commit
message first, run them through `humanizer`, then post what it returns.

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

The PR exists. The job is to take in what reviewers said, act on it, and answer them.

### 1. Collect every comment

```
gh pr view --json number,url,title,body,comments,reviews
gh api repos/{owner}/{repo}/pulls/<number>/comments
```

The last call is the one that matters: inline comments on specific lines do not
appear in `gh pr view`, and they are usually where the real objections are.

List all of them before doing anything: who said it, `file:line` if inline, and what
they are asking for. Do not rank them yet and do not skip the ones you disagree with.

### 2. Sort them

Split into three groups and show the user the split before you touch code:

- **Act** — a real problem, or a change you agree with.
- **Answer** — a question, or a misunderstanding that needs a reply and no code change.
- **Push back** — you think the reviewer is wrong. Say why, in one sentence, and let
  the user decide. Never silently ignore a comment; an unanswered comment reads as
  agreement that never happened.

If a comment is ambiguous about what the reviewer wants, ask them in the reply rather
than guessing at a change. In the face of ambiguity, refuse the temptation to guess.

### 3. Act on the first group

Make the changes. Same rules as any other work: minimum code, no unrequested extras,
tests first if the comment revealed a missing case.

Run the tests and keep the actual output. You will need it in the reply.

### 4. Stage, commit, push

Stage by name. The commit message says what feedback it addresses, not "address review
comments".

```
git push
```

### 5. Reply, one reply per comment

Reply to each inline comment where it was made, not in a single summary at the bottom.
A reviewer should not have to hunt for the answer to their own question.

```
gh api repos/{owner}/{repo}/pulls/<number>/comments/<comment-id>/replies \
  -f body="<the reply>"
```

Each reply says what changed and where, or why nothing changed. Lead with the answer.
No thanking, no "good catch", no restating their comment back at them.

Draft all the replies and the round-up comment, run the batch through `humanizer` in
one pass, then post what it returns.

Then one top-level comment covering the round as a whole. It uses the same fields as
the PR body, so a reviewer can answer "what problem does this solve" and "where is the
evidence" from this comment alone, without scrolling back to a description written
several rounds ago.

```
gh pr comment <number> --body "$(cat <<'EOF'
**What changed:** <one sentence, plain English. What is now different for a user or
the system.>

**Why:** <which review comment or issue this answers. Name the reviewer and the
`file:line` where they raised it.>

**Pushed back on:** <what you did not change, and the reason in one sentence. Write
"Nothing" if you took every comment.>

**Evidence:** <what you ran this round and what it produced, in whatever form the proof
took. Paste the real output. Then what this round leaves unverified.>
EOF
)"
```

Every field gets a real answer. "Evidence: none, nothing was run" is a legitimate
answer and a useful one. An empty field, or one padded to look filled, is worse than
the free-form paragraph this replaced.

### 6. Print the PR URL

### 7. Post a plain-English summary in the conversation for the user

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
