---
name: regression-bisect
description: Find the exact commit that introduced a regression using git bisect. Use when something used to work and now does not, when a test that previously passed now fails, when a performance or memory regression appeared between releases, or when the user says "this broke", "worked last week", or "which commit caused this". Prefer this over reading diffs or reasoning about likely causes.
---

# Regression bisect

Do not reason about which commit "probably" caused a regression. Bisect finds it
in log2(n) steps with certainty. A 1000-commit range resolves in ~10 builds.

## Step 1: Build a reproducer that exits with a status code

This is the whole job. Everything else is mechanical.

The reproducer must exit **0 when the code is good** and **non-zero when bad**.
Make it as fast and as narrow as possible — it will run once per bisect step.

```bash
#!/usr/bin/env bash
# /tmp/bisect-test.sh
set -euo pipefail

# Build. If the build itself fails, this commit cannot be judged: exit 125.
make -j"$(nproc)" >/dev/null 2>&1 || exit 125

# The actual check. Narrow it to the single failing case.
pytest tests/test_parser.py::test_nested_arrays -q
```

Exit code contract for `git bisect run`:

| Code | Meaning |
|---|---|
| 0 | good |
| 1–124, 126, 127 | bad |
| 125 | untestable, skip this commit |
| 128+ | abort the bisect |

**Store the script outside the repository** (`/tmp`, or a path in
`.git/info/exclude`). Bisect checks out old trees; a script inside the worktree
will be overwritten or deleted mid-run.

`chmod +x` it. Verify it manually on a known-bad commit (expect non-zero) and a
known-good one (expect zero) before starting. A miscalibrated script silently
produces a confident wrong answer.

## Step 2: Establish the bounds

```bash
git status                      # must be clean; stash or commit first
git bisect start
git bisect bad                  # current HEAD is broken
git bisect good v1.4.0          # last known-good tag or commit
```

If no known-good point is known, walk backwards until the reproducer passes:

```bash
git checkout HEAD~50 && /tmp/bisect-test.sh; echo "exit=$?"
```

Double the step each time until it passes, then use that as the good bound.

## Step 3: Run it

```bash
git bisect run /tmp/bisect-test.sh
```

Report the `<sha> is the first bad commit` output verbatim, plus
`git show --stat <sha>`.

Then, always:

```bash
git bisect reset
```

Leaving a repository in a bisecting state is a trap for the next session.

## Variants

**Performance regression** — bisect on a threshold, not on pass/fail:

```bash
ns=$(hyperfine --style none --export-json /dev/stdout ./bench \
     | jq '.results[0].mean')
awk -v t="$ns" 'BEGIN { exit (t > 0.250) ? 1 : 0 }'
```

Pick the threshold to sit clearly between the known-good and known-bad
measurements, not at the midpoint of noise. Run the benchmark on both bounds
first to see the spread.

**Flaky failure** — the reproducer must loop, or bisect will mark good commits
bad and give a wrong answer:

```bash
for i in $(seq 1 30); do ./run-test || exit 1; done
```

If the failure rate is below ~10%, raise the iteration count until a known-bad
commit fails reliably. If it cannot be made reliable, bisect is the wrong tool —
use `dynamic-analysis` (TSan for races, ASan for use-after-free) instead.

**Noisy history** — skip merge commits or vendored-code churn:

```bash
git bisect start --first-parent    # follow mainline only
git bisect skip $(git rev-list --merges good..bad)
```

**Bug is in a dependency, not your code** — bisect the dependency's repo with
your reproducer pinned against it, or bisect your lockfile history.

## After the culprit is found

1. Read the diff. Explain the mechanism — *why* that change causes this
   failure. If the mechanism is not clear, the bisect result may be a
   coincidence of a flaky reproducer; re-verify by checking out the parent
   commit and confirming it passes.
2. Write a regression test that fails on the bad commit and passes on its
   parent. Show both runs.
3. Then fix it.

Do not revert without understanding the mechanism. The bad commit may have been
fixing something else.
