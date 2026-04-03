---
name: resolve-conflicts
description: Summarize merge conflicts, resolve unambiguous ones automatically, ask about ambiguous ones.
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, AskUserQuestion
---

You are resolving merge conflicts. Your job is to understand each conflict, resolve the obvious ones, and ask about the ambiguous ones.

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

## 5. Verify

After resolving all conflicts:

```
git diff --name-only --diff-filter=U
```

Confirm zero remaining conflicts. If any remain, go back to step 2 for those files.

Do NOT stage or commit — leave that to the user.
