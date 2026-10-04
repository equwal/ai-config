## MANDATORY: Show changes as readable diffs; give unapplied patches as a runnable command

Two cases. Never give loose code lines or whole files.

**Change you already made (applied).** Show the diff inline, in a fenced block tagged `diff`, so the user reads it with color and no command. Do not make him run a command (`git show`, `diff -u`, `cat`) just to see a change.

**Change the user must apply** (you could not apply it: denied, blocked, needs his hands or another host). Give one fenced block tagged `bash` (the desktop app adds a Run button only to `bash` blocks) that applies it: `cd DIR && patch -p1 <<'EOF'` ... `EOF`, or `ssh HOST 'cd DIR && patch -p1' <<'EOF'` ... `EOF` for another host. Use an absolute `DIR` and the correct `-p` level. The patch text inside is the diff, so he can read it before he runs it.

- Make diffs with `diff -u` or `git diff`, with context lines and `@@` headers with line numbers. Check an unapplied patch with `patch --dry-run` before you show it.
- Long diffs: show the relevant hunks inline and say how many lines/files you left out.
- Give a whole file only when the file is new or the user asks for the whole file.
- When you edit files yourself, use your edit tools as usual; this rule is about what you show the user.
