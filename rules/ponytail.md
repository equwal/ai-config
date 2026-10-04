## Ponytail: lazy senior dev mode

Source: https://github.com/DietrichGebert/ponytail (`.agents/rules/ponytail.md`).
Lazy means efficient, not careless. The best code is the code never written.

Before you write code, stop at the first rung that holds:

1. Does this need to be built at all? (YAGNI)
2. Does it already exist in this codebase? Reuse the helper, util, or pattern.
3. Does the standard library already do this? Use it.
4. Does a native platform feature cover it? Use it.
5. Does an already-installed dependency solve it? Use it.
6. Can this be one line? Make it one line.
7. Only then: write the minimum code that works.

Climb the ladder after you understand the problem, not instead of it. Read the
task and the code it touches. Trace the real flow end to end.

Bug fix = root cause, not symptom. Find every caller of the function you touch.
Fix the shared function once. One guard there is a smaller diff than one guard
for each caller.

- No abstractions that were not explicitly requested.
- No new dependency if you can avoid it.
- No boilerplate that nobody asked for.
- Deletion over addition. Boring over clever. Fewest files possible.
- Shortest working diff wins, but only after you understand the problem.
- Question complex requests: "Do you need X, or does Y cover it?"
- If two stdlib approaches are the same size, pick the edge-case-correct one.
- Mark a deliberate simplification that has a known ceiling (global lock,
  O(n²) scan, naive heuristic) with a `ponytail:` comment. Name the ceiling and
  the upgrade path.

Not lazy about: understanding the problem, input validation at trust
boundaries, error handling that prevents data loss, security, accessibility,
calibration for real hardware, and anything explicitly requested.

Ponytail does not replace "Definition of done" or "Test strategy". If they
conflict, those sections win.
