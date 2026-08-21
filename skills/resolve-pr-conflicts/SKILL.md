---
name: resolve-pr-conflicts
description: Summarize merge conflicts, resolve unambiguous ones automatically, ask about ambiguous ones.
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, AskUserQuestion
---

You are resolving merge conflicts. Your job is to understand each conflict, resolve the obvious ones, and ask about the ambiguous ones.

## 0. Fetch remote and surface conflicts

First, fetch the latest remote state and simulate the merge so you catch conflicts that are visible on GitHub but not yet local:

```bash
git fetch origin
```

The PR states its own base. Ask it, and do not guess:

```bash
BASE=$(gh pr view --json baseRefName -q .baseRefName)
echo "Merging against: origin/$BASE"
```

Empty or failed? Stop and say so. A default here merges against the wrong branch and
reports the conflicts of a merge nobody asked for, which looks exactly like a real
result. This user's repos use both `main` and `develop`, so there is no safe guess.

Attempt the merge without committing:

```bash
git merge --no-commit --no-ff origin/$BASE 2>&1
```

- If the merge completes cleanly → no conflicts, report clean and stop. Run `git merge --abort` to leave the repo unchanged.
- If the merge reports conflicts → proceed to step 1.

## 1. Identify conflicts

```
git diff --name-only --diff-filter=U
```

If no conflicts, say so and stop.

## 2. Read and classify each conflict

For every conflicted file, read the file and examine each conflict marker (`<<<<<<<` ... `=======` ... `>>>>>>>`).

Classify each conflict as:

- **Unambiguous**: One side is clearly correct (e.g., one side adds new code while the other didn't change, import ordering, formatting-only differences, one side is a strict superset of the other).
- **Ambiguous**: Both sides made meaningful, different changes to the same logic. Requires a judgment call.

## 3. Present summary

Output a conflict summary before making any changes:

**Merge Conflict Summary — N files, M conflicts**

For each conflict:
- **File**: path and line range
- **Ours**: one-line description of what our branch did
- **Theirs**: one-line description of what the incoming branch did
- **Classification**: 🟢 Unambiguous / 🟡 Ambiguous
- **Proposed resolution**: what you plan to do (and why)

Always state assumptions and rationale for every resolution, even unambiguous ones.

## 4. Resolve

- **Unambiguous conflicts**: Resolve them directly using Edit. State what you did and why in the summary.
- **Ambiguous conflicts**: Ask the user how to proceed. Present the two sides clearly and suggest options if you can, but do not pick one without confirmation.

## 5. Verify and complete

After resolving all conflicts:

```
git diff --name-only --diff-filter=U
```

If any remain, go back to step 2 for those files.

Once all conflict markers are gone, complete the merge:

```bash
git add <resolved files>
GIT_EDITOR=true git merge --continue
```

Then push so the PR on GitHub reflects the resolved state:

```bash
git push
```

Finally, confirm the PR is mergeable:

```bash
gh pr view --json mergeable,mergeStateStatus -q '{mergeable: .mergeable, status: .mergeStateStatus}'
```

Report the final status to the user. If `mergeable` is `MERGEABLE`, the conflicts are fully cleared on GitHub.
