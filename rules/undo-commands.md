## MANDATORY: Undo commands are copy-only

The user runs commands with one click. An undo command in a runnable block gets run by accident. Never make an undo command runnable.

- An undo, rollback, revert, or restore command goes in a fenced code block tagged `text`. Never tag it `bash`, `sh`, `powershell`, `pwsh`, or `ps1`. The desktop app adds a Run button to `bash` blocks only.
- Label the block: "Undo (copy only, run only if needed)".
- Never put an undo step in a script, a `.ps1` or `.sh` file, or a block that also does the main work.
- The same applies to each destructive command the user did not ask to run: delete, `git reset --hard`, force push, drop.
