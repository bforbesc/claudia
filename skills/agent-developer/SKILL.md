---
name: agent-developer
description: Build a feature from a frozen plan through a fixed chain: tests, watch them fail, implement, verify, scan, review, record what the build learned. Use when the user says /agent-developer, "build this feature", "implement X", or asks for new functionality that does not yet exist. Takes the topic of a plan already frozen by /freeze-plan.
---

You are the orchestrator. You stay on Opus and you do not write the feature
yourself. Sonnet subagents do the writing, one job each, in order.

Walk the steps in sequence. Do not skip ahead and do not run two write steps at once.

A subagent is allowed to spawn subagents of its own, up to three layers down. Do not
let it. Every handoff in this chain is yours to make, because a worker that delegates
puts a layer between the code and the only session that has the contract.

## 1. The frozen plan is the input

The argument is the topic. Read `docs/decisions/<topic>.md`. It must carry
`Frozen at:` plus `## Requirements`, `## Design`, `## Tasks` and `## Planned files`.

You do not write this file and you do not edit it. `/freeze-plan` wrote it, and it
is the specification you get graded against. A specification you authored is one you
will grade yourself against.

No frozen plan? Two paths, and the line between them is a number:

- **Under ~50 lines in a single file**: the user states the contract inline, in five
  parts, and you build from that. **Goal**, one sentence. **Success criteria**, how
  we know it works. **Constraints**, what it must not break. **Non-goals**, what this
  explicitly does not do. **Assumptions**, what is taken as true without checking. Any
  of the first four missing, ask and stop. If the user cannot state the success
  criteria, this is not ready to build, and saying so is the useful answer.
- **Anything larger**: stop and run `/freeze-plan`. Do not draft the plan here.

## 2. Check the plan against the repo

```bash
git rev-parse HEAD
```

Different from the plan's `Frozen at`? The tree moved after the freeze, so
`## Planned files` was verified against code that is no longer there. Re-freeze. Do
not build against it and do not reason about whether the drift matters.

Then read `## Planned files` and show the user the list before touching anything. A
file list that surprises them means the plan is wrong, and that is `/freeze-plan`
again, not an improvisation here.

Over ~200 lines of expected change, do the first task in `## Tasks` only. Each task
is one red-green slice and cites the R-ids it closes, so the next run picks up at the
first task whose R-ids have no `## Where it lives` entry.

If the chain stops before §6, that file describes something nobody built. Add
`## Abandoned` with the reason, or delete it.

## 3. Tests, and nothing else

Spawn `test-writer` with the task it is covering and the R-ids that task closes. Each
requirement names the test that proves it, so the test names are already decided.

It writes tests. It does not write implementation. If it comes back having touched
implementation code, that run is void: revert and re-spawn.

## 4. The gate: watch them fail

```bash
just verify
```

Show the user the actual failure output. Not a summary of it, the output.

Then check it: does each test fail for the reason it should? A test that fails with
a collection error or an import error is not evidence of anything.

Nothing proceeds until the tests are proven to fail correctly. This is the step that
stops the tests and the code from being wrong in the same direction, which is the
one way this whole chain can quietly produce something broken.

If a test looks like it tests the wrong thing, fix that now. After the code exists,
you will not be able to tell.

If a test shows a requirement itself is wrong, the chain stops here. Go back to the
user, and handle the frozen plan before you do: it now specifies something nobody is
going to build. `## Abandoned` with the reason, or a new `/freeze-plan` for the
requirement that replaces it. Never edit the requirement in place.

## 5. Implement

Spawn `implementer` with the failing tests and the contract.

It writes the minimum code that makes those tests pass. It never edits a test. If it
reports that a test looks wrong, stop and bring it to the user; do not let it change
the test.

## 6. Verify

```bash
just verify
```

Show the output. Green, or go back to step 5 with what actually failed.

No `just verify`? Run `/agent-scaffold` first, or run the repo's real test command and say
which one you used.

## 7. Scan

Spawn in parallel:

- `security-scanner` — secrets, injection, authorization, data exposure
- `silent-failure-hunter` — swallowed errors, empty catch blocks, fallbacks that
  hide a failure

Both agents are told a finding needs a concrete failure: the input, and what goes
wrong. So every finding that comes back is already actionable, and there is no
priority label to sort by. Fix them, or name the ones you are not fixing under
`## Risks accepted` at §8, each with the reason.

An unfixed finding that is not written down is the one outcome this step cannot
produce. That is also the only way this chain ships a known problem silently.

## 8. Review and record

You review the whole thing yourself: every requirement against the test that was
supposed to prove it, the tests against the code, and the scan findings. A
requirement with a passing test that tests something else is the failure this step
exists to catch.

Then append to `docs/decisions/<topic>.md`:

```markdown
## Where it lives
- R1 — `path/to/file.py:42` — the code that implements it
- R1 — `tests/test_thing.py:8` — the test that pins it

## Risks accepted
- <anything from step 7 you chose not to fix, and why>

## Deviations
- <where the build diverged from the frozen plan, and why>
```

Append only. Leave Decision, Why, Requirements, Design, Tasks and Planned files
exactly as `/freeze-plan` wrote them, even where the build proved them wrong. That is what
Deviations is for. A decision doc quietly edited to match what was built stops being
evidence of anything, and the divergence is the part worth keeping. Later runs append
to Deviations.

Every R-id appears under Where it lives, or it was not built. Say which.

Never describe what the code does in this file. If a sentence describes behaviour,
delete it and point at the line instead.

If the run produced a rule worth enforcing on future code, write it to
`.claude/rules/<topic>.md` with `paths:` frontmatter. A rule in a loose note is a
rule nobody applies.

## Then stop

Do not open a PR. That is `/open-pr`, and it starts with an inspection this chain has not
done. Report what was built, the actual test output, and what you did not verify.
