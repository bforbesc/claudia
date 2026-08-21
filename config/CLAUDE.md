# Coding principles
Minimum code that solves the problem.
No speculative features, no abstractions for single use, no configurability nobody asked for, no handling for impossible cases.
Touch only what the task requires
Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Complex is better than complicated.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
Special cases aren't special enough to break the rules.
Although practicality beats purity.
Errors should never pass silently.
Unless explicitly silenced.
In the face of ambiguity, refuse the temptation to guess.
There should be one-- and preferably only one --obvious way to do it.
Although that way may not be obvious at first.
Now is better than never.
Although never is often better than right now.
If the implementation is hard to explain, it's a bad idea.
If the implementation is easy to explain, it may be a good idea.
Namespaces are one honking great idea -- let's do more of those!
Every file should not exceed 1000 lines.
Tests first. Write the failing test, show it fail, then write the code.

# Truth
Code is memory and tests hold what the system does.
`.claude/rules/<topic>.md` at the project level, should hold the rules that must be enforced, scoped with respective `paths:`.
`docs/decisions/<topic>.md` holds which decisions were made and why (this cannot be found in the code), and points at the files that sustain that decision and that implement it.
Cite `file:line` for any claim about existing code.
Subagents should report findings and `file:line`, never paste file contents back.
Never claim a check passed without running it.
Ask first: deleting files, auth, billing, user data, public APIs, infrastructure and deploy config.
"I could not verify X" is a valid answer. Say it instead of guessing.

# Writing
Direct answer first, short bullets, plain human language, simple and clear, and define terms on first use.
No em dashes, no emoji headers, no tables where a sentence works.
Use neutral declarative statements, no addressing the reader, no meta-notes about your process.
End explanations of changes with "Summary: <one sentence to one paragraph>".