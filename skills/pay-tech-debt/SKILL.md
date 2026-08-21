---
name: pay-tech-debt
description: Measure accumulated debt in a named scope (a path, a PR, a commit range, or a subsystem), then pay one item with tests green before and after and no behaviour change. Use when the user says /pay-tech-debt, "clean this up", "pay down the debt", or after a run of fast feature work.
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, Agent
---

You measure debt with commands inside a named scope, show what you found, and pay
exactly one item.

Two failure modes to avoid, and they pull in opposite directions. One is a rewrite
wearing a cleanup's clothes. The other is a list of things that look untidy and cost
nobody anything. Both come from skipping the measurement and going on impression.

## 0. Scope it

Never the whole repo unless the user asks for the whole repo. On a large codebase a
team owns two or three areas, and debt outside them is somebody else's list. An
unscoped run buries the items they can act on under items they cannot.

Resolve whatever the user gave into a concrete list of paths, then show that list
before measuring anything:

- **A path or directory**: that is the scope.
- **A PR number or link**: the files that PR touched.

  ```bash
  gh pr diff <number> --name-only
  ```

  Use this to clean up behind a merge, or ahead of one.
- **A range of work**: the files a set of commits touched.

  ```bash
  git diff <base>..HEAD --name-only
  ```

- **A feature or subsystem by name**: no command resolves this, so resolve it and show
  your work. The `docs/decisions/` entry for it names files under `## Where it lives`
  and `## Planned files`, and grep finds the rest. Show the file list and get it
  confirmed before measuring. A guessed scope produces a list about the wrong code.
- **Nothing given**: ask which of the above. Do not default to the repo.

Everything below runs against that scope, written as `<scope>`. A finding outside it
does not go on the list, however tempting.

## 1. Is the scope green

```bash
just verify
```

Red is not debt, it is broken. Stop and say what failed. You cannot prove a cleanup
changed no behaviour without a passing baseline to compare against, and `just verify`
covers the repo, so a failure outside your scope still blocks you.

Keep this output. Step 4 compares against it.

## 2. Measure

Run all of these. A finding you did not get from a command does not go on the list.

**Files over the cap.** `just size` covers the repo, so keep only what falls inside
`<scope>`. Anything it reports got in before the gate existed or by a bypass.

**Dead code.** For each suspicious symbol in `<scope>`, grep the *whole repo*
including tests, never just the scope:

```bash
grep -rn "<symbol>" --include='*.py' .
```

One hit is the definition, and one hit means nothing calls it. The scope decides which
symbols you check; it must never decide where you look for callers, or you will delete
something a caller outside the scope still needs.

**Tests that assert nothing.** These are the worst kind of debt, because they read
as coverage:

```bash
grep -rn "skip\|xfail\|^\s*pass\s*$\|assert True" <the tests covering scope>
```

**Swallowed errors.** Spawn `silent-failure-hunter` with `<scope>` as its scope. It
takes a file list or a directory and already knows what to look for.

**Stale decision docs.** Spawn `comment-analyzer` with the `docs/decisions/` entries
that name a file in `<scope>`. It verifies each `file:line` pointer still resolves and
still says what the entry claims. A decision doc pointing at deleted code is debt with
authority.

**Rules nobody follows.** For each file in `.claude/rules/` whose `paths:` match
`<scope>`, check whether those paths still match anything and whether the rule is
actually held to. A rule that is routinely violated is either wrong or unenforced;
both are findings.

## 3. Show the list and stop

Ranked by what it costs to leave, not by how easy it is to fix. Each item: the
command that found it, the `file:line`, and one sentence on what it costs.

Then stop. The user picks one item. Not two, and not "all the easy ones".

If the list is empty, say so and name both what you checked and the scope you checked
it in. A clean scope is a real outcome, and it is not a claim about the repo.

## 4. Pay it

One item. The tests do not change.

- **A test has to change to make this work?** Stop. That is a behaviour change
  wearing debt's clothes, and it goes through `/freeze-plan` and `/agent-developer`
  like any other change.
- **Deleting code?** Prove nothing calls it and cite the grep. Reading files finds
  what you looked for; grep finds what is there.
- **Splitting a file over the cap?** Move code, do not rewrite it. The diff should be
  almost entirely lines relocated, and anything else in there needs a reason.
- Ask before deleting a file, per the standing rule.

## 5. Verify

```bash
just verify
```

Show the output next to step 1's. Same tests, same results, same count. A test that
newly passes is as much a red flag as one that newly fails: the cleanup changed
behaviour and you did not mean to.

## 6. Record only if a decision moved

Nothing goes in `docs/decisions/` for a cleanup. What changed is in the code, and the
code is the record.

The exception: if paying this item reversed something a decision doc recorded, append
one line to that entry's `## Deviations` saying what changed and why. Do not touch
its Decision or Why.

## Then stop

Report the scope, the item you paid, the two `just verify` outputs, and what is still
on the list unpaid. Do not open a PR; that is `/open-pr`, and it starts with an inspection this
did not do.
