---
name: walkthrough
description: Generates a linear walkthrough of a scoped part of the codebase to pay down cognitive debt before planning. Use when unfamiliar with code about to be touched.
allowed-tools: Read, Grep, Glob, Bash
---

You are building a linear reading guide through one part of a codebase, so that whoever reads it next can plan a change without re-deriving how the code works.

**Write no files.** The deliverable is the walkthrough in this conversation, read once, in the session that then plans the change. What survives is whatever the plan's Requirements and Design carry forward.

A walkthrough is the fastest-rotting thing you could commit: line-numbered snippets of code that is about to be edited, and nothing checks it afterwards. Re-running this against the current code costs less than reading a stale copy.

## 1. Scope it

The argument is a subsystem, module, or entry point. If none was given, ask which one before doing anything else.

Never walk through a whole repository. A walkthrough that covers everything explains nothing, and the cost of reading it exceeds the cost of reading the code. If the named scope turns out to be too broad to trace as a single line of execution, say so and propose two or three narrower entry points to pick from.

## 2. Orient from macro to micro

Before tracing anything, place the scope inside the system. A reader who knows what happens next but not where they are cannot plan a change.

Establish, in this order:

- **The repo's shape** — the top-level layout, from an actual `ls`, `glob`, or `tree` run
- **Where the scope sits in it** — one sentence on the subsystem's job, and which layer it belongs to
- **Its boundary** — what calls into it and what it calls out to, each cited `file:line`
- **Its internal parts** — the handful of files or units the trace will visit, and what each one is for

Structural claims follow the same rule as code: derived from a command you ran, or cited `file:line`, or not claimed. A directory tree written from memory is the one part of a walkthrough that can be wrong while looking authoritative.

## 3. Read the source, then plan

Read the actual files in scope before deciding the ordering. You cannot plan a trace through code you haven't opened.

Then stop and show the plan:

- Where the scope sits in the system, in one sentence — so a wrong framing gets caught here, not after the document is written
- The entry point you'll start from, and why it's the right door in
- The ordered list of steps you intend to trace
- Where the trace ends (the output, the return value, the side effect)
- Anything in scope you intend to skip, and why

Wait for confirmation before building. This stop exists because the reader's mental model is the product — if the ordering is wrong, everything downstream is wasted, and it's far cheaper to fix an outline than a finished document.

## 4. Build it

Output it here, in the conversation. No file.

Open with the orientation from step 2, then trace execution linearly from the entry point to the output. Each step names which part of the map it is inside, so the reader can relocate without scrolling back. Follow the order the machine runs things, not the order the files happen to sit in. Each step picks up where the previous one left off.

### Code snippets must be captured, not typed

Every snippet in the document comes from a command you actually ran — `sed -n '<start>,<end>p' <file>`, `grep -n`, or `cat`. Paste the captured output.

Never retype, paraphrase, summarize, or reformat code into the document. The whole value of a walkthrough is that the reader can trust the quoted code matches the repository. Code you typed from memory is code that quietly drifts from reality, and a walkthrough with invented snippets is worse than no walkthrough — it teaches a wrong model with the authority of a document.

Label each snippet with `<file>:<start>-<end>` so the reader can jump to it.

### What each step says

For every step in the trace:

- **What calls this** — the caller, by `file:line`
- **What it returns** — the shape of the value, or the side effect if it returns nothing
- **What it assumes** — preconditions the code relies on but does not check
- **What breaks if the assumption fails** — the concrete failure: exception, silent wrong answer, corrupted state

The assumption/failure pair matters most. It's the part a reader cannot get by skimming the code themselves, and it's what turns a walkthrough into something useful for planning a change.

## 5. Close honestly

End with an **Unverified** section listing anything you inferred rather than read: behavior you assumed from a function name, a call you didn't follow into a dependency, a branch you never traced, and any structural claim from step 2 that nothing in the repo actually states. A module's purpose is usually nowhere written down, so most of the orientation is inference and belongs here. Mark inference plainly so the reader knows which claims to double-check.

If an algorithm is still unintuitive after you've traced it, say that too, and name what specifically remains unclear. "This part is still opaque to me" is genuinely useful to the next reader. Confident prose over a piece of code you don't understand is not.