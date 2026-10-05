## Install tasks: all 8 AIs on both computers

An install task is done only when every AI on both computers has the thing. That is 8 targets: 4 AIs on 2 computers.

| AI | Config folder (same path on both computers) |
|---|---|
| Claude Code | `~/.claude/` (CLAUDE.md, settings.json, skills/) |
| Codex | `~/.codex/` (AGENTS.md, config.toml, skills/) |
| Copilot CLI | `~/.copilot/` (copilot-instructions.md, mcp-config.json, skills/) |
| Antigravity | `~/.gemini/` (GEMINI.md, config/mcp_config.json, skills/, antigravity/skills/) |

Computers: the Windows PC, and the Linux desktop `g` (${g_ip}, `ssh ${g_user}@${g_ip}`).

- Install, register, or copy the thing for each of the 8 targets. Commit each config file in its git repo before you edit it (rule no-bak).
- If the thing has a GitHub gist (for example the agent-manager skill), edit the gist too, so that it matches the installed copy: `gh gist edit <id> -f <file> <local file>`.
- If an AI is not installed on a computer yet, write its config files anyway, so that it gets them at its first start. Report each missing AI.
- Verify each target with a command. Report one line for each of the 8 targets: done, or blocked with the cause.
