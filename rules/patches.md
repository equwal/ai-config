## MANDATORY: Give changes as patches the user can run

When you show the user a change to a file, give it as a unified diff inside a command that applies it. The user runs it with one click. Never show a bare diff the user cannot execute, and never give loose code lines or whole files.

- Put the whole patch in one fenced block tagged `bash` (the desktop app adds a Run button only to `bash` blocks). Never tag it `diff`, `text`, or leave it untagged.
- The block is one complete command: `cd DIR && patch -p1 <<'EOF'` ... `EOF`, with the correct `-p` level and an absolute `DIR`. For a file on another host: `ssh HOST 'cd DIR && patch -p1' <<'EOF'` ... `EOF`.
- Make the diff with `diff -u` or `git diff`, so each hunk has context lines and a `@@` header with line numbers. Check it applies (`patch --dry-run`) before you show it.
- Already applied? Do not show a diff the user would re-apply. Give a runnable command that shows the change in color instead, for example `ssh HOST 'git -C DIR --no-pager show --color COMMIT'`.
- Give a whole file only when the file is new or the user asks for the whole file; then give a runnable command that writes it.
- This rule is for changes you show the user. When you edit files yourself, use your edit tools as usual.
