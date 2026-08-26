# Laws of Software Engineering — Reference

Used by the `decision-review` skill. Lookup index first, then the full text of all 56 laws grouped by their source category.
Source: lawsofsoftwareengineering.com

Track-to-category mapping:

| Track | Source categories | Laws |
|---|---|---|
| BUILD | Architecture, Design | 1–9, 39–44 |
| SCOPE | Planning | 19–24 |
| TEAM | Teams | 10–18 |
| QUALITY | Quality | 25–35 |
| GROWTH | Scale | 36–38 |
| *(cross-cutting)* | Decisions | 45–56 |

Pull only the laws that bind on the user's actual answers. Three to five, maximum.

---

## BUILD — architecture and design

| If the answers show... | Reach for |
|---|---|
| A big-bang design with no working small version | Gall's Law (2), Second-System Effect (6) |
| A public or widely-consumed interface | Hyrum's Law (1), Postel's Law (27), Principle of Least Astonishment (44) |
| Complexity being "simplified away" | Tesler's Law (4), Law of Leaky Abstractions (3) |
| Anything crossing a network boundary | CAP Theorem (5), Fallacies of Distributed Computing (7) |
| A change touching many modules | Law of Unintended Consequences (8) |
| Scope creep dressed as platform ambition | Zawinski's Law (9), YAGNI (39) |
| Cleverness in the design | Kernighan's Law (31), KISS (41) |
| Duplication, or knowledge in two places | DRY (40) |
| Deep chaining or tight coupling | Law of Demeter (43), SOLID (42) |
| Abstraction layers added speculatively | YAGNI (39), SOLID (42) — note its overapplication caveat |

## SCOPE — planning and estimates

| If the answers show... | Reach for |
|---|---|
| An estimate with no buffer, or a padded one | Hofstadter's Law (22) |
| "We're almost done" | Ninety-Ninety Rule (21) |
| A soft or self-chosen deadline | Parkinson's Law (20) |
| Optimization before measurement | Premature Optimization (19) |
| A metric being used as a goal | Goodhart's Law (23) |
| Nothing being measured because it's hard to quantify | Gilb's Law (24) |

## TEAM — people, ownership, process

| If the answers show... | Reach for |
|---|---|
| Adding people to recover a schedule | Brooks's Law (11), Ringelmann Effect (13) |
| Team boundaries mismatched with system boundaries | Conway's Law (10) |
| Knowledge concentrated in one person | Bus Factor (17) |
| Output concentrated in a few contributors | Price's Law (14) |
| A large team or org coordinating informally | Dunbar's Number (12) |
| Promotion or role-fit friction | Peter Principle (16), Dilbert Principle (18) |
| Managers and engineers talking past each other | Putt's Law (15) |
| A single approver or reviewer bottleneck | Amdahl's Law (36) — cross-track, the serial-fraction ceiling applies to people too |

## QUALITY — tests, debt, defect posture

| If the answers show... | Reach for |
|---|---|
| Shortcuts accumulating without a payback plan | Technical Debt (29) |
| A known-broken thing everyone has stopped mentioning | Broken Windows Theory (28) |
| No routine for incremental cleanup | Boy Scout Rule (25) |
| A slow, fragile, top-heavy test suite | Testing Pyramid (32) |
| Tests that haven't caught anything in months | Pesticide Paradox (33) |
| Reliance on review to catch defects | Linus's Law (30) — only holds when people actively look |
| Debugging cost underestimated relative to writing | Kernighan's Law (31) |
| A system that must keep absorbing real-world change | Lehman's Laws (34) |
| Effort spread evenly across all features | Sturgeon's Law (35) |
| Missing error handling, validation, or fallbacks | Murphy's Law (26) |
| Tolerant input handling, or strictness debates | Postel's Law (27) |

## GROWTH — scale and capacity

| If the answers show... | Reach for |
|---|---|
| A serial fraction limiting parallel speedup | Amdahl's Law (36) |
| A goal of bigger workloads rather than faster ones | Gustafson's Law (37) |
| Value that compounds with each additional user | Metcalfe's Law (38) |
| Churn risk in a network-effect product | Metcalfe's Law (38) — the same math runs in reverse |
| More hardware or workers thrown at a bottleneck | Amdahl's Law (36) — more cores expose bottlenecks, they don't remove them |

---

## Cross-cutting — Decisions (45–56)

These apply to the *reasoning*, not the artifact. Run them in the debias pass on every track, and surface at most one or two.

| Reasoning failure | Law |
|---|---|
| Past investment doing the arguing | Sunk Cost Fallacy (48) |
| Confidence inversely tracking experience | Dunning-Kruger (45) |
| Evidence selected to fit the framing | Confirmation Bias (50) |
| Reasoning about the diagram, not the running system | Map Is Not the Territory (49) |
| A complicated explanation where a simple one fits | Occam's Razor (47) |
| Assuming bad intent behind bad code | Hanlon's Razor (46) |
| No stated failure condition | Inversion (54) — run a pre-mortem |
| Convention accepted without derivation | First Principles Thinking (53) |
| Enthusiasm for newness over proven value | Hype Cycle & Amara's Law (51) |
| Dismissing an old technology for being old | Lindy Effect (52) |
| Effort spread across causes without finding the vital few | Pareto Principle (55) |
| Silence mistaken for agreement | Cunningham's Law (56) — post a wrong draft to draw correction |

---

## Architecture

**1. Hyrum's Law** — Hyrum Wright, 2012
With a sufficient number of API users, all observable behaviors of your system will be depended on by somebody.
- With enough users, every observable behavior becomes an implicit contract.
- Even bugs get depended on; fixing them is a breaking change for someone.
- The real API is not the spec — it's the full behavior observed in the wild.

**2. Gall's Law** — John Gall, 1975
A complex system that works is invariably found to have evolved from a simple system that worked.
- Big-bang designs fail because unknowns pile up faster than you can validate them.
- Build a small core that works, then grow it.

**3. The Law of Leaky Abstractions** — Joel Spolsky, 2002
All non-trivial abstractions, to some degree, are leaky.
- Using a high-level tool doesn't free you from understanding what's underneath.
- Design for when abstractions fail, not around the failure.

**4. Tesler's Law (Conservation of Complexity)** — Larry Tesler, 1980s
Every application has an inherent amount of irreducible complexity that can only be shifted, not eliminated.
- If users face too many steps, you shifted complexity to the wrong place.
- Good design absorbs complexity internally.

**5. CAP Theorem** — Eric Brewer, 2000
A distributed system can guarantee only two of: consistency, availability, partition tolerance.
- Partitions are unavoidable, so the real choice is consistency vs. availability.
- MongoDB favors consistency; Cassandra favors availability.

**6. Second-System Effect** — Fred Brooks, 1975
Small, successful systems tend to be followed by overengineered, bloated replacements.
- The first system is lean because constraints force discipline.
- Be suspicious of grand rewrites that promise everything.

**7. Fallacies of Distributed Computing** — L. Peter Deutsch, 1994
Eight false assumptions new distributed-system designers make.
- The network is not reliable, free, or secure. Treat all eight as false.
- Retries, timeouts, encryption, dynamic discovery are not optional.

**8. Law of Unintended Consequences** — Robert K. Merton, 1936
Whenever you change a complex system, expect surprise.
- Side effects can be good, bad, or perverse (worsening the original problem).
- A fix in one module can break another that quietly depended on old behavior.

**9. Zawinski's Law** — Jamie Zawinski, 1995
Every program attempts to expand until it can read mail.
- Popular software accumulates features until it tries to do everything.
- Adding features is easy; saying no to the wrong ones is hard.

---

## Teams

**10. Conway's Law** — Melvin Conway, 1967
Organizations design systems that mirror their own communication structure.
- Silos in the org become silos in the code.
- Want a target architecture? Reshape teams to match it (Inverse Conway).

**11. Brooks's Law** — Frederick P. Brooks Jr., 1975
Adding manpower to a late software project makes it later.
- New hires need ramp-up and consume senior capacity.
- Cut scope or schedule instead of adding headcount.

**12. Dunbar's Number** — Robin Dunbar, 1992
A cognitive limit of about 150 stable relationships per person.
- Past that limit, informal coordination breaks and hierarchy fills in.
- Effective working groups are 5–15, not 150.

**13. The Ringelmann Effect** — Max Ringelmann, 1913
Individual productivity decreases as group size increases.
- Social loafing plus rising coordination overhead.
- Small focused teams with clear ownership outperform large diffuse ones.

**14. Price's Law** — Derek de Solla Price, 1963
The square root of the total number of participants does 50% of the work.
- In a 100-person org, ~10 people produce half the output.
- Losing core contributors has outsized impact.

**15. Putt's Law** — Archibald Putt, 1981
Those who understand technology don't manage it, and those who manage it don't understand it.
- The gap produces unrealistic deadlines and ignored engineers.
- Tech leads and CTOs bridge it by keeping a foot in each world.

**16. Peter Principle** — Laurence J. Peter, 1969
In a hierarchy, every employee tends to rise to their level of incompetence.
- Promotion rewards current performance, not fitness for the next role.
- IC career tracks let top engineers grow without becoming managers.

**17. Bus Factor** — Software folklore, 1990s
The minimum number of team members whose loss would put the project in serious trouble.
- A factor of 1 is a single point of failure in team knowledge.
- Pairing, code review, and docs raise it.

**18. Dilbert Principle** — Scott Adams, 1996
Companies promote incompetent employees to management to limit the damage they can do.
- Result: an incompetent manager and one fewer productive engineer.
- Dual career tracks avoid this by design.

---

## Planning

**19. Premature Optimization (Knuth's Optimization Principle)** — Donald Knuth, 1974
Premature optimization is the root of all evil.
- 97% of code is not a bottleneck.
- Write clear, correct code first; profile, then optimize the real hotspot.

**20. Parkinson's Law** — Cyril Parkinson, 1955
Work expands to fill the time available for its completion.
- Extra time goes to gold-plating and minor tweaks.
- Time-boxing (sprints) is the direct counter.

**21. The Ninety-Ninety Rule** — Tom Cargill, 1985
The first 90% of the code takes 90% of the time; the remaining 10% takes the other 90%.
- "Almost done" is a danger zone.
- 90% + 90% = 180% of your original estimate.

**22. Hofstadter's Law** — Douglas Hofstadter, 1979
It always takes longer than you expect, even when you take into account Hofstadter's Law.
- Hidden tasks and integration surprises extend timelines.
- Add buffers, and plan for the buffers to be consumed too.

**23. Goodhart's Law** — Charles Goodhart, 1975
When a measure becomes a target, it ceases to be a good measure.
- Ticket counts, coverage %, and velocity all get gamed.
- Pair metrics with qualitative judgment.

**24. Gilb's Law** — Tom Gilb, 1988
Anything you need to quantify can be measured in some way better than not measuring it.
- An approximate measure beats blindness.
- Start measuring, then refine.

---

## Quality

**25. The Boy Scout Rule** — Robert C. Martin, 2008
Leave the code better than you found it.
- Small cleanups compound into a healthier codebase.

**26. Murphy's Law / Sod's Law** — Edward A. Murphy Jr., 1949
Anything that can go wrong will go wrong.
- Add error handling, input validation, graceful fallbacks.
- Write edge-case tests before production finds them.

**27. Postel's Law** — Jon Postel, 1980
Be conservative in what you do, be liberal in what you accept from others.
- Tolerant input handling improves resilience.
- Too much tolerance masks producer bugs and adds security risk.

**28. Broken Windows Theory** — Hunt and Thomas, 1999
Don't leave broken windows (bad designs, wrong decisions, poor code) unrepaired.
- One unrepaired bug signals that low quality is acceptable.
- Fix problems while small.

**29. Technical Debt** — Ward Cunningham, 1992
Technical debt is everything that slows us down when developing software.
- Every shortcut borrows time from the future and accrues interest.
- Intentional debt with a repayment plan can be useful.

**30. Linus's Law** — Eric S. Raymond, 1997
Given enough eyeballs, all bugs are shallow.
- Only holds when people are actively looking, not passively watching.

**31. Kernighan's Law** — Brian Kernighan, 1974
Debugging is twice as hard as writing the code in the first place.
- If you write at the limit of your cleverness, you can't debug it later.

**32. Testing Pyramid** — Mike Cohn, 2009
Many fast unit tests, fewer integration tests, few UI tests.
- Catch most bugs at the cheapest level.
- An inverted pyramid produces a slow, fragile suite.

**33. Pesticide Paradox** — Boris Beizer, 1990
Repeatedly running the same tests becomes less effective over time.
- Fixed tests can't catch defects in code they never exercise.

**34. Lehman's Laws of Software Evolution** — Manny Lehman, 1974
Software that reflects the real world must evolve, and that evolution has predictable limits.
- Each change adds complexity, slowing future changes unless you refactor.
- A team can only absorb so much change per release.

**35. Sturgeon's Law** — Theodore Sturgeon, 1957
90% of everything is crap.
- The challenge is identifying the high-impact 10%.

---

## Scale

**36. Amdahl's Law** — Gene Amdahl, 1967
Speedup from parallelization is limited by the fraction of work that cannot be parallelized.
- The sequential fraction sets a hard ceiling; fix serial paths first.
- Decision bottlenecks work the same way: one approver limits the team.

**37. Gustafson's Law** — John L. Gustafson, 1988
Significant parallel speedup is possible by increasing the problem size.
- More processors let you tackle bigger problems in the same time.
- Design to scale out: add nodes and add scope.

**38. Metcalfe's Law** — Robert Metcalfe, 1980
The value of a network is proportional to the square of the number of users.
- Works in reverse too: user loss shrinks value faster than linearly.

---

## Design

**39. YAGNI (You Aren't Gonna Need It)** — Ron Jeffries, late 1990s
Don't add functionality until it is necessary.
- Speculative hooks and abstractions add complexity you may never need.

**40. DRY (Don't Repeat Yourself)** — Andy Hunt and Dave Thomas, 1999
Every piece of knowledge must have a single, unambiguous, authoritative representation.
- DRY applies to knowledge, not just similar-looking code.

**41. KISS (Keep It Simple, Stupid)** — Kelly Johnson, 1960s
Designs and systems should be as simple as possible.
- Simple code is faster to understand, debug, and hand off.

**42. SOLID Principles** — Robert C. Martin, early 2000s
Five guidelines that make code more maintainable and scalable.
- Single responsibility, open/closed, Liskov, interface segregation, dependency inversion.
- Overapplying SOLID creates abstract layers for no gain.

**43. Law of Demeter** — Ian Holland, 1987
An object should only interact with its immediate friends, not strangers.
- Chaining through neighbors (a.b.c.do()) ties code to deep structure.

**44. Principle of Least Astonishment** — Programming folklore, 1960s
Software and interfaces should behave in the way that least surprises users and other developers.
- Behavior should match the mental model users already bring.

---

## Decisions

**45. Dunning-Kruger Effect** — Dunning and Kruger, 1999
The less you know about something, the more confident you tend to be.
- Real experts speak in ranges and trade-offs, not certainties.

**46. Hanlon's Razor** — Robert J. Hanlon, 1980
Never attribute to malice that which is adequately explained by stupidity or carelessness.
- Approach a colleague's bad code with questions, not accusations.

**47. Occam's Razor** — William of Ockham, 14th century
The simplest explanation is often the most accurate one.
- When debugging, start with the simplest explanation.

**48. Sunk Cost Fallacy** — Richard Thaler, 1980
Sticking with a choice because you've invested in it, even when walking away helps you.
- Set explicit decision points: if target X isn't met by date Y, re-evaluate.

**49. The Map Is Not the Territory** — Alfred Korzybski, 1933
Our representations of reality are not the same as reality itself.
- When the running system contradicts your model, update the model.

**50. Confirmation Bias** — Peter Wason, 1960
A tendency to favor information that supports our existing beliefs.
- When debugging, ask what you'd expect to see if your theory is wrong.

**51. The Hype Cycle & Amara's Law** — Roy Amara, 1960s
We overestimate the effect of a technology in the short run and underestimate it in the long run.
- Evaluate new tools by proven value, not buzz.

**52. The Lindy Effect** — Albert Goldman, 1964
The longer something has been in use, the more likely it is to continue being used.
- Invest in timeless skills (algorithms, SQL, core languages) over new frameworks.

**53. First Principles Thinking** — Aristotle
Breaking a complex problem into its most basic blocks and building up from there.
- Estimate from fundamentals, not from how long similar work took before.

**54. Inversion** — Carl Jacobi, 19th century
Solving a problem by considering the opposite outcome and working backward.
- Run a pre-mortem: assume the project failed, then name the reasons.

**55. Pareto Principle (80/20 Rule)** — Vilfredo Pareto, 1906
80% of the problems result from 20% of the causes.
- Profile and find the hot 20%; the ratio is rarely exactly 80/20.

**56. Cunningham's Law** — Ward Cunningham, 1980s
The best way to get the correct answer on the Internet is not to ask a question, it's to post the wrong answer.
- Propose a draft or prototype to get concrete feedback instead of silence.
