---
name: prep-pr
description: Pre-PR inspection of the current branch. Reports what to look at; changes nothing.
allowed-tools: Bash, Read, Grep, Glob
---

You are inspecting a branch before it becomes a pull request. You produce a report. You change nothing.

## Report only

Do not write a PR description. Do not commit, stage, push, or edit any file. Do not run `gh`.

`Bash` is available because this job needs `git` and `grep` — not as permission to act on the branch. The value of this skill is that the user can run it at any moment without wondering what it touched.

## Evidence rule

Every finding traces to a command you actually ran. For the caller search and the diff stats, show the literal command and its output in the report, not a paraphrase of it.

Never report a caller list assembled by reading files. Reading finds what you looked for; grep finds what's there. A caller you missed is exactly the failure this report exists to prevent, so the reader needs to see the search that was run in order to judge whether it was wide enough.

## 1. Find the base branch

Don't hardcode `main` — this user's repos also use `develop`.

```
git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||'
```

If that returns nothing, check which of `main`/`develop`/`master` exists and say which one you used.

## 2. Size the diff

```
git diff <base>...HEAD --stat
```

Report total lines changed. Over 200, propose concrete commit boundaries — name the actual files and the specific commit each group would become, in order. "This should be split" without the split is not advice the reader can act on.

## 3. Changed surface and its callers

List every function, class, or constant whose signature or behavior changed.

For each one, grep the repo for callers and report which callers are **not** in this diff. Those are the ones that silently kept the old expectations.

## 4. What no type checker catches

Flag these specifically, because they pass every static check and fail at runtime:

- Return types that changed shape
- New exceptions raised
- Changed default argument values
- Renamed dictionary keys or config keys

## 5. Scope creep

Read `agent-docs/plans/` for the plan covering this branch. List anything in the diff that nobody asked for: new docstrings, defensive `try`/`except`, extra helper functions, generated comments.

Then note where the implementation diverged from the plan. Divergence isn't automatically wrong — it's something the reviewer should know was a decision rather than an accident.

## 6. Context check

Will the PR state the higher-level goal and link the issue or spec? If not, flag it. A reviewer who has to reconstruct why the change exists reviews the code instead of the decision.

## 7. Evidence check

List what the author should include so the review is worth the reader's time:

- Manual testing notes — what was actually run, and what it showed
- Reasoning behind specific implementation choices, where a reviewer would otherwise wonder
- Screenshots or video, if visible behavior changed

## 8. Manual verification checklist

End with a checklist of what to actually run before opening the PR — real commands, in order.
