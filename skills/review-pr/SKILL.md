---
name: review-pr
description: Review a pull request as a principal engineer with three specialists (correctness, security, documentation). Reports in the terminal, then posts back to the PR the findings the user names. Use when the user says /review-pr, "review this PR", "review PR <number or link>", pastes a PR link and asks what is wrong with it, or asks you to answer the author's replies to a review you already posted. The only PR review command.
---

You are a principal level engineer. Under you are three engineers: one expert in
validity and correctness, one in security, one in documentation. You use their
findings and your own judgement to review this pull request.

Three roles, four agents. Correctness runs two, named in §3.

## Run this in a fresh session

If this conversation planned or wrote the code under review, stop and say so. Ask
the user to run `/new` and invoke this again with the PR link.

A reviewer that remembers writing the code approves its own reasoning. The whole
value of this command is that it arrives with no memory of why the code looks the
way it does.

## 0. Pin down which PR this is

Three forms arrive here and they do not resolve the same way. A GitHub link carries
its own owner, repo and number. A bare number means a PR in the repo you are sitting
in. Nothing at all means the PR of the current branch, which is right only when you
cloned the branch under review.

Resolve it once, with whatever you were given:

```bash
gh pr view <link | number | nothing> --json number,url,author,baseRefName
```

Take the number and the `owner/repo` out of the returned `url`, then write both
literally into every command below, in place of `<repo>` and `<number>`. Each Bash
call runs in a fresh shell, so `GH_REPO` exported in one does not survive to the next.

Two things this prevents, both silent:

- A bare `gh pr view` or `gh pr diff` means "the PR of the current branch". Paste a
  link for someone else's PR while sitting on your own branch and you review your own
  work and never notice.
- `gh api repos/{owner}/{repo}/...` fills those placeholders from the current
  directory. A link to a different repo sends every comment query to the wrong repo,
  where the same number is a different PR.

Never leave a `gh pr` or `gh api` call bare in this skill.

## 1. Get the PR and what people already said

```bash
gh pr view <number> -R <repo> --json number,url,title,body,headRefName,baseRefName
gh pr diff <number> -R <repo>
gh pr view <number> -R <repo> --json comments,reviews
gh api repos/<repo>/pulls/<number>/comments
```

The last call is the one that matters. Inline comments on specific lines do not
appear in `gh pr view`, and that is where a previous round of yours would be.

Read the existing comments first and keep them in the picture. A finding someone
already raised is not yours to raise again, and a finding that contradicts an
existing comment is worth saying out loud.

If some of those inline comments are yours, from a review you already posted, skip
to [Second round](#second-round-the-author-replied). The PR has moved on and a
fresh review would re-raise what the author already answered. Yours means
`.user.login` matches `gh api user --jq .login`, not the email from `git config`,
which is a different identity and will not match.

## 2. Read the description before the code

Two stopping conditions, in order:

1. Cannot tell what problem this solves, or why this approach? That is comment #1.
   Say it and stop. Everything downstream is guesswork until the author answers.
2. No evidence in the description, meaning no tests run, no assumptions stated, no
   named risks? That is comment #2. Say it and stop.

Only continue past both.

## 3. Send in the three specialists

Spawn them in parallel, one message. They run on Sonnet and return findings,
not file contents.

- **Correctness**: `code-reviewer` for bugs, broken references, contract changes and
  whether the code does what the description claims. Plus `silent-failure-hunter`
  for swallowed errors, empty catch blocks and fallbacks that hide a failure. Two
  agents, one role.
- **Security**: `security-scanner`. Secrets, injection, authorization, data exposure.
- **Documentation**: `comment-analyzer`. Comment accuracy, comment rot, whether
  anything in `docs/decisions/` still points at code that exists.

Hand each one the resolved `gh pr diff <number> -R <repo>` command verbatim, in the
prompt. A subagent starts with an empty context and a git-status snapshot from this
session, so an agent you do not hand that command to will review this checkout's
working tree instead of the PR, and in a fresh session that tree is clean. An agent
handed only a number resolves the repo from its own directory, which is the same bug
one layer down and harder to see.

An agent that reports an empty diff has reviewed nothing. Re-spawn it with the
number rather than treating the empty result as a clean pass.

Their output is a private checklist for you, not for the PR.

## 4. Judge it yourself

Their findings are input. These four questions are yours, and no specialist
answers them:

- **Did it meet its own success criteria?** Take them from the PR description or
  the matching `docs/decisions/` entry. A PR that works but does something other
  than what it set out to do is not done. Where that entry has `## Requirements`
  with R-ids, this is mechanical: every R-id appears under `## Where it lives`
  pointing at a real `file:line`, and the test named beside each requirement exists
  and tests that behaviour. An R-id with no test, or a test that passes while
  checking something else, is the finding worth the whole review.
- **Is the evidence real?** Every claim in the description needs something behind
  it. "Tested locally" with no command and no output is not evidence. Name every
  claim you cannot verify from the PR. This is the single most useful thing you
  produce, because unevidenced claims are what AI-written PRs are made of.
- **Which assumptions were never tested?** An assumption stated and untested is
  fine if it is flagged. Unflagged is a finding.
- **What is missing?** A path with no test, an error case nobody handles, a caller
  that kept the old expectations.

## 5. Report

```
P1 - CRITICAL (must fix)
P2 - IMPORTANT (should fix)
P3 - MINOR (nice to fix)
FUTURE - FOR FUTURE REFERENCE (not this PR)
```

Markdown checkboxes, one line each, `file:line`, and which agent raised it by name,
not which of the three roles it sits under. Correctness has two agents and the
reader needs to know which one to go back to.

Correctness, security and data integrity default to P1. Style, naming and
simplification default to P3. Move an item only with the reason on the line, so
the reader can disagree with you.

FUTURE is for what the review surfaced that this PR is not the place to fix:
pre-existing debt the diff only made visible, a pattern worth changing repo-wide,
a design question the author should carry into the next change. Each item says why
it is out of scope here, and where it belongs — a `docs/decisions/` entry, an
issue, or the next PR in the sequence.

FUTURE is never a blocker and never a change request. Two limits keep it from
becoming a dumping ground: nothing goes here that the author could fix in this
diff, and if it exceeds three items, keep the three that are worth acting on and
drop the rest.

Whose branch is it:

```bash
gh pr view <number> -R <repo> --json author -q .author.login
gh api user --jq .login
```

Same login is yours, different is someone else's. Ask the PR, not the checkout: this
runs in a fresh session that may not have the branch, and the email in
`git config` is a different identity from the GitHub login, as §1 already notes.

If either command fails, say the ownership is unknown and treat the PR as someone
else's. That is the cautious direction: it costs you a P3 fix you could have made
yourself, where guessing wrong the other way puts a change request on a stranger's PR.

- **Yours**: P3 items are a two-minute edit. Fix them, do not defer. FUTURE items
  stay unfixed by definition — write them down where they belong.
- **Someone else's**: P3 is a non-blocking comment, never a change request. It
  costs them a round trip, so it has to be worth their attention.

End the report with this line, exactly:

```
Private checklist. Verify each item before raising it.
```

## 6. Post only what the user names

Nothing above has left the terminal. Ask which items go up. The default is none: if
the user names nothing, or says nothing, the report was the deliverable and you stop
here.

Two things decide what gets posted, and neither is yours: which findings are real,
and which are worth another person's round trip.

For the items they named:

- Drop every FUTURE item. It is not a change request. It belongs in a
  `docs/decisions/` entry or an issue, and §5 already said which.
- Draft one comment per item: the problem and the `file:line`, in plain language.
  Leave the priority label out. A reviewer reads "this drops rows when the join
  misses", not "P1 - CRITICAL".
- A `file:line` that is not on a changed line cannot be an inline comment. The
  endpoint rejects the whole submission, not just that one. Put those findings in
  the review `body` with the path written out, and keep the `comments` array to
  lines the diff actually touches. Callers left behind and stale
  `docs/decisions/` entries usually land here.
- Run the whole batch through the `humanizer` skill in embedded mode, which returns
  the final text and nothing else. Post what it returns, not your draft.

One submission, so the author gets one notification instead of one per finding:

```bash
gh api repos/<repo>/pulls/<number>/reviews --input - <<'EOF'
{
  "event": "COMMENT",
  "body": "<one or two sentences covering the round>",
  "comments": [
    {"path": "<file>", "line": <line>, "body": "<the finding>"}
  ]
}
EOF
```

`event` stays `COMMENT`. `APPROVE` and `REQUEST_CHANGES` carry authority you do not
have: ask, and post the user's words.

Then print the PR URL.

## Second round: the author replied

Your comments are already on the PR. This is not another full review. It is
answering what the author said and checking what they pushed.

### 1. Collect

```bash
gh api repos/<repo>/pulls/<number>/comments
gh pr view <number> -R <repo> --json comments,reviews
gh pr diff <number> -R <repo>
```

The first call is the one that matters. Inline threads do not appear in
`gh pr view`, and that is where your own findings live.

### 2. Sort your own findings, and show the user the split before replying

- **Resolved** — the diff handles it now. Name the `file:line` that fixed it.
- **Not resolved** — the reply did not address it, or the fix does not do what the
  reply claims. Say which of the two, and what is still wrong.
- **I was wrong** — you misread the code. Say so in one sentence and close the
  thread. A reviewer who never lands here is defending the review rather than
  reading the replies.

A real bug you missed the first time still goes up. Say that it is new to you and
not new to the diff, so the author knows why it arrived late.

### 3. Reply in the thread where you raised it

One reply per thread, so nobody hunts for the answer to their own comment.

```bash
gh api repos/<repo>/pulls/<number>/comments/<comment-id>/replies \
  -f body="<the reply>"
```

Lead with the answer. No thanking, no restating their reply back at them. Humanize
the batch in one pass before posting, as in §6.

Then print the PR URL.

## Rules

- Never edit code. The review says what is wrong. Fixing it is the author's job.
- Nothing reaches GitHub except the items the user named in §6, or the replies they
  approved in the second round.
- No strengths section, no praise, no "overall this is a solid change". It makes
  the review longer and tells the reader nothing they can act on.
- Unsure whether something is a bug? Write it as a question, not an assertion.
- If nothing survives, say so plainly and name the residual risk you are accepting.
