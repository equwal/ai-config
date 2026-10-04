---
name: structural-refactor
description: AST-aware structural search and replace across a codebase using ast-grep. Use for renames, function signature changes, API migrations, deprecation sweeps, or codemods spanning more than two files; for finding all call sites of a pattern rather than a string; and for writing project-specific lint rules that encode team conventions. Use instead of sed, awk, or regex whenever the target is code rather than plain text.
---

# Structural refactor

Regex does not understand code. It matches inside strings, comments, and
unrelated identifiers, and it misses anything reformatted across lines. That is
how half-finished renames ship. `ast-grep` matches on the syntax tree.

Order of preference for a rename or signature change:

1. **LSP rename** (`rename_symbol`) if the language server supports it — it
   understands scope and imports, and is always correct.
2. **ast-grep** for anything the LSP cannot express: cross-language sweeps,
   call-pattern rewrites, argument reordering, API migrations.
3. **sed** never, for code.

## Preflight

```bash
command -v ast-grep || command -v sg
ast-grep --version
```

Install: `cargo install ast-grep`, `npm i -g @ast-grep/cli`, `brew install
ast-grep`. The binary is `ast-grep`, aliased `sg` (which collides with
`sg(1)` on some Linux systems — prefer the full name in scripts).

## Pattern syntax

| Token | Matches |
|---|---|
| `$VAR` | exactly one named node, captured |
| `$$$ARGS` | zero or more nodes (argument lists, statement bodies), captured |
| `$_` | one node, not captured |

Patterns are written as code, not as regex. Whitespace and formatting are
irrelevant; structure is what matters.

## Workflow — always in this order

**1. Search first. Read the matches before rewriting anything.**

```bash
ast-grep run -p 'db.query($SQL, $$$ARGS)' -l python
```

Count them, and check for false positives:

```bash
ast-grep run -p 'db.query($SQL, $$$ARGS)' -l python --json=compact | jq length
```

**2. Preview the rewrite as a diff.** `run` with `--rewrite` prints a diff and
changes nothing until told to apply.

```bash
ast-grep run -p 'db.query($SQL, $$$ARGS)' \
             --rewrite 'db.execute($SQL, params=[$$$ARGS])' \
             -l python
```

**3. Apply.** Use `--interactive` to accept or reject each hunk when the pattern
is loose, or `--update-all` for a bulk apply once the diff has been reviewed.

```bash
ast-grep run -p '...' --rewrite '...' -l python --update-all
```

**4. Verify.** Formatter, type checker, tests. A structural rewrite that
type-checks is usually correct; one that does not, is not. Commit the codemod
separately from any behavioural change so the diff stays reviewable.

Work on a clean tree — `git status` before, `git diff` after. `--update-all`
edits files in place with no undo.

## Rule files

Anything run more than once, or enforced on every PR, belongs in a rule file
rather than a shell command. Rules support constraints patterns cannot express:
`inside`, `has`, `not`, `follows`, and metavariable regex filters.

```yaml
# rules/no-bare-except.yml
id: no-bare-except
language: python
severity: error
message: Bare except swallows KeyboardInterrupt and SystemExit.
note: Catch a specific exception type, or `except Exception` if truly generic.
rule:
  pattern: |
    try:
      $$$BODY
    except:
      $$$HANDLER
```

```bash
ast-grep scan --rule rules/no-bare-except.yml
ast-grep scan                      # all rules, via sgconfig.yml
```

`sgconfig.yml` at the repo root registers the rule directories:

```yaml
ruleDirs:
  - rules
```

Verify exact rule schema fields against `ast-grep scan --help` and the
installed version's docs — the YAML schema has evolved.

This is the cheapest way to encode a convention that keeps recurring in review.
When the same correction is made twice, write a rule instead of a third comment.

## Common patterns

```bash
# Find all callers of a method, regardless of receiver name
ast-grep run -p '$OBJ.deprecated_method($$$)' -l ts

# Add an argument to every call
ast-grep run -p 'connect($HOST, $PORT)' \
             --rewrite 'connect($HOST, $PORT, timeout=30)' -l python

# Unwrap a redundant wrapper
ast-grep run -p 'str($X)' --rewrite '$X' -l python     # review each: too loose

# Locate every unsafe block in a Rust crate
ast-grep run -p 'unsafe { $$$BODY }' -l rust
```

The `str($X)` example is deliberately included as a warning: it matches cases
where the conversion is load-bearing. Loose patterns need `--interactive`, not
`--update-all`.

## Limits

- ast-grep is syntactic, not semantic. It cannot resolve imports, aliases, or
  types. `foo.bar()` and `from x import bar; bar()` are different patterns.
- For type-directed refactors, use the language's own tooling: `cargo fix`,
  `tsc` codemods via ts-morph, `gofmt -r` or `gopls rename`.
- After any large sweep, grep for the old name anyway to catch what the pattern
  missed — string literals, docs, config, comments. Those are text, and text
  tools are correct for them.
