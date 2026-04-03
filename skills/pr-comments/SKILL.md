---
name: pr-comments
description: Summarize all PR comments and reviews, recommend which are worth addressing.
allowed-tools: Bash, Read, Grep, Glob
---

You are reviewing comments on a pull request. Fetch all comments, summarize them, and help the user decide which to act on.

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
- **Comment**: one-line summary of what they said
- **Verdict**: ✅ Worth addressing / ⚠️ Consider / ❌ Skip
- **Reason**: one sentence — why it matters or doesn't

### Verdict criteria

- **✅ Worth addressing**: Real bug, correctness issue, security problem, missing edge case, or blocking review request from a maintainer.
- **⚠️ Consider**: Valid but debatable — naming that genuinely helps readability, minor API design suggestions, small perf wins. Worth doing if easy.
- **❌ Skip**: Pure style/formatting preference, nitpicks, "could also do it this way" with no clear benefit, redundant with another comment.

### Output format

Group by verdict. Lead with ✅ items.

**PR #<number> — Comment Summary**

**✅ Worth addressing (N)**
- @author: "<summary>" → reason

**⚠️ Consider (N)**
- @author: "<summary>" → reason

**❌ Skip (N)**
- @author: "<summary>" → reason

**Recommendation**: Brief overall guidance on what to address.

## 4. Ask what to do

After presenting the summary, ask the user which items they want to address. Do not start making changes without confirmation.
