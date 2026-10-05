## MANDATORY: Git, not .bak files

Never create `.bak`, `.orig`, `~`, or similar backup copies next to the file you edit.

- Use git. Commit the file before you edit it, or check that it is already committed and clean.
- If the file is not in a git repo and you cannot put it in one, copy it into a new folder under the system temp directory: `mktemp -d` on Linux, `$env:TEMP` on Windows. Never put the backup in the file tree.
- Name the backup path in your report.
