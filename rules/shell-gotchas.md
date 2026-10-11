## Shell gotchas

- On Windows, write multi-line PowerShell to a .ps1 file and run it. Never give me here-strings to paste (they hang at the >> prompt). Put a here-string only inside a .ps1 file, and give me one `pwsh -NoProfile -File <file>.ps1` line to run. This overrides the here-string advice under "One message, one click".
- When piping a single result in PowerShell, wrap it with @() so it stays an array.
- Never use Select-Object -First to truncate lists that drive installs.
- On Debian hosts, use pipx/apt or a venv, never bare `pip install`.
- In test harnesses, don't override PATH in ways that break stty/timeout. Long-running background jobs must log failures loudly (no silent PATH failures).
