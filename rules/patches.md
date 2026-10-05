## MANDATORY: Show changes as readable diffs; give unapplied patches as a runnable command

Two cases. Never give loose code lines or whole files.

**Change you already made (applied).** Show the diff inline, in a fenced block tagged `diff`, so the user reads it with color and no command. Do not make him run a command (`git show`, `diff -u`, `cat`) just to see a change.

**Change the user must apply** (you could not apply it: denied, blocked, needs his hands or another host). Give one fenced block tagged `bash` (the desktop app adds a Run button only to `bash` blocks) that applies it. The Run button types into his Terminal panel, which runs PowerShell, so a bash heredoc fails there. For another host, pipe a here-string script to ssh (see "One message, one click"); inside it, `cd DIR && patch -p1 <<'PATCH'` ... `PATCH`. Use an absolute `DIR` and the correct `-p` level. The patch text inside is the diff, so he can read it before he runs it.

- Make diffs with `diff -u` or `git diff`, with context lines and `@@` headers with line numbers. Check an unapplied patch with `patch --dry-run` before you show it.
- Long diffs: show the relevant hunks inline and say how many lines/files you left out.
- Give a whole file only when the file is new or the user asks for the whole file.
- When you edit files yourself, use your edit tools as usual; this rule is about what you show the user.

**One message, one click.** The user prefers one large runnable block over several small commands. Put every step he must run (all patches, installs, checks, the commit) in a single `bash`-tagged block, so the desktop app's Run button does it all in one click. Never split it into blocks he has to copy or run one by one.

- His Terminal panel can be Windows PowerShell 5.1. It strips `"` inside native-program arguments, prefixes piped text with a BOM, and ends lines with CRLF. A copied block can also lose its tabs.
- For a remote host, send the script on stdin: a `@'` ... `'@` here-string piped to `ssh HOST 'awk ''{gsub(/[^ -~\t]/,x)}1'' | sh'`. Keep `"` out of the ssh argument. Start the script with `set -e`.
- Never rely on a literal tab in the block. Make one with `t=$(printf '\t')`, or append Makefile recipes with `printf '\t...'`. Prefer `sed` line edits guarded by a `sha256sum -c` of the file over patches whose context holds tabs or trailing spaces.
- Before you give the block, run it with a dry-run switch in both `powershell.exe -File` and `pwsh -File`.
