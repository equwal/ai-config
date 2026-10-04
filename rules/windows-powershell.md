## MANDATORY on the Windows PC: PowerShell 7.6 syntax

This section applies on the Windows PC only, not on the Linux desktop `g`.

The PC has PowerShell 7.6 (`pwsh.exe`). The Claude Code agent shell and the desktop Terminal panel both run it. Checked 2026-10-03. `powershell.exe` is the old Windows PowerShell 5.1. Most broken commands on this PC came from mixing the two.

- Check your own shell once per session: `$PSVersionTable.PSVersion`. On 7.x, `&&`, `||`, `?:`, `??` and `?.` work. On 5.x they fail with "The token '&&' is not a valid statement separator". Then use `A; if ($?) { B }`.
- Never wrap a command in `powershell -Command "..."`. That starts 5.1, and your shell expands each `$` inside the double quotes first. For a child shell, write a `.ps1` file and run `pwsh -NoProfile -File <file>.ps1`.
- Put a command longer than about 3 lines, or one with nested quotes, in a `.ps1` file. Do not build one long line of escaped quotes.
- Unix commands do not exist: `head`, `tail`, `wc`, `sed`, `awk`, `grep`, `readlink`, `base64`, `printf`, `which`, `touch`, `rsync`, `wsl`. A Unix flag on a PowerShell alias (`ls -la`, `rm -rf`, `mkdir -p`) fails with "A positional parameter cannot be found". Use `Select-Object -First N`, `Get-ChildItem -Force`, `Remove-Item -LiteralPath <p> -Recurse -Force`, `New-Item -ItemType Directory -Force <p>`, `(Get-Content f).Count`, `(Get-Command x).Source`, `$env:X = '1'`.
- These native programs exist: `ssh`, `scp`, `tar`, `git`, `gh`, `curl.exe`, `py -3`, `node`, `go`.
- Single quotes are literal. Double quotes expand `$var` on the PC. Put a remote `ssh` command in single quotes, and write a literal `'` inside it as `''`.
- A pipe into a native program adds CRLF: `'a' | prog` sends `a\r\n`. A Linux host then gets a stray `\r`. Copy files with `scp -O` instead of piping text into `ssh`. Hosts without an SFTP server, such as `g`, need `scp -O`.
- Do not use `2>&1` on a native program. Check `$LASTEXITCODE`.
- The UI language is Russian (`ru-RU`), so many errors are in Russian. "Не удается найти путь" means the path was not found. Check exit codes, not English error text.
