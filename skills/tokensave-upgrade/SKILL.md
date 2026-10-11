---
name: tokensave-upgrade
description: Upgrade the tokensave code-graph MCP server on the Windows PC and on desktop g to the latest aovestdipaperino/tokensave release, and refresh its Claude permissions and rules. Use when the user says "tokensave upgrade", "update tokensave", or doctor says a newer tokensave is out.
---

# Upgrade tokensave on the PC and on g

## When to use

The user asks to upgrade tokensave, or a new release is out. Both computers run
it: the PC natively, g (musl) as a glibc binary through the Guix loader.

## Steps

### PC (Windows)

1. Check: `tokensave --version; gh release list -R aovestdipaperino/tokensave -L 3`
2. Upgrade: `tokensave upgrade`. Do not pass `--kill`: other sessions run
   `tokensave serve`. Windows moves the running image to
   `%TEMP%\.tokensave.*.__relocated__.exe`, and those sessions keep the old version
   until they restart.
3. New tools need Claude permissions, and the rules text may change. Back up first:
   copy `~/.claude.json`, `~/.codex/config.toml`, `~/.copilot/mcp-config.json` and
   `~/.claude/settings.json` into a new folder under `$env:TEMP`. Then run
   `tokensave reinstall`.
4. Keep only the Claude parts of the reinstall: `~/.claude/settings.json` (permissions)
   and `~/.claude/rules/tokensave.md` (rules text). Undo the rest (see Gotchas):
   - `git -C ~/.codex checkout -- AGENTS.md`, `git -C ~/.copilot checkout -- copilot-instructions.md`
   - restore `~/.codex/config.toml` from the TEMP backup
   - move `~/.codex/config.toml.bak`, `~/.claude/rules/tokensave.md.bak`, and any new
     `%APPDATA%\Code\User\mcp.json` and `prompts\` into the TEMP backup folder
5. Render the MCP entries from the canonical source:
   `py -3 W:\src\agent-config-sync\acsync.py --dry-run render`, then without `--dry-run`.
   It writes the 4 PC MCP files from `[mcp.tokensave]` in `W:\src\ai-config\acsync.toml`.
6. Commit each changed repo (`~/.claude`, and ai-config if `acsync.toml` changed). Stage
   files by name: `~/.codex/config.toml` and `~/.gemini/config/*` often hold unrelated
   app edits. To commit only one hunk of `config.toml`, build the blob from
   `HEAD:config.toml` with the one replacement, `git hash-object -w --stdin --path config.toml`,
   then `git update-index --cacheinfo 100644,<blob>,config.toml`.
7. Push. ai-config: `git push git@github.com:equwal/ai-config.git main` and
   `git push --receive-pack='runuser -u aiconfig -- git-receive-pack' root@honjimaku.com:/srv/git/ai-config.git main`.

### Desktop g

1. Never run `tokensave upgrade` or `tokensave doctor` on g (see Gotchas).
2. Download and check, in a new temp dir:
   ```sh
   d=$(mktemp -d); cd $d; u=https://github.com/aovestdipaperino/tokensave/releases/download/vX.Y.Z
   curl -fsSLO $u/tokensave-vX.Y.Z-x86_64-linux.tar.gz; curl -fsSLO $u/SHA256SUMS
   grep " tokensave-vX.Y.Z-x86_64-linux.tar.gz$" SHA256SUMS | sha256sum -c
   tar -xzf tokensave-vX.Y.Z-x86_64-linux.tar.gz
   ```
3. Test it with the loader paths from `~/.local/bin/tokensave` before you replace anything:
   `$G/ld-linux-x86-64.so.2 --library-path $G:$C ./tokensave --version`
4. Replace: `cp tokensave ~/.local/libexec/tokensave.new; mv ~/.local/libexec/tokensave.new ~/.local/libexec/tokensave`
5. Permissions and rules: compare the `mcp__tokensave__*` entries of PC and g
   `~/.claude/settings.json` with `json.load`, insert the missing lines as text, and
   commit in g `~/.claude` (no remote). Copy the PC `rules/tokensave.md` blob byte-exact
   (`git cat-file blob` on the PC, `scp -O`, compare `git hash-object` on g), then commit.
6. `rm -rf $d`.

## Gotchas

- `tokensave reinstall` touches every agent it lists in `~/.tokensave/state.toml`
  (`installed_agents`): it re-serializes the whole Codex `config.toml`, writes rules
  blocks into `~/.codex/AGENTS.md` and `~/.copilot/copilot-instructions.md`, creates
  VS Code `mcp.json` and `prompts/copilot-instructions.md`, and leaves `.bak` files next
  to the files it edits. The user's instruction files carry no tokensave block on purpose.
- A minor release does the same "silent resync" on first launch. Check the four config
  repos with `git status` after any upgrade.
- MCP entries are rendered by acsync. A hand edit of `~/.claude.json` or the other MCP
  files is reverted by the next `acsync sync`. Change `acsync.toml` instead.
- On g, `/proc/self/exe` is the Guix `ld-linux` loader, not tokensave. `upgrade` would
  try to replace the loader in the read-only store. `doctor` "auto-repairs" Claude hooks
  in `~/.claude/settings.json` with the loader as the command, which breaks every hook.
  Undo with `git -C ~/.claude checkout -- settings.json`.
- Over non-interactive ssh, `~/.local/bin` is not on PATH: prefix `PATH=$HOME/.local/bin:$PATH`.
- A schema bump (v17 to v18 in 7.14) re-indexes each project at its first start.
- Since 7.14.0 (issue #606), `tokensave serve` outside any project starts with no default
  project. The old `serve-tokensave` wrappers are no longer needed.

## Verify

- PC: `tokensave --version`, and `tokensave doctor`: the "Claude Code integration"
  section is all green (MCP binary, hooks, permissions, rules).
- g: `~/.local/bin/tokensave --version`.
- MCP answers on both: pipe one `initialize` JSON-RPC line (from a file, not an
  inline quoted string) into the MCP entry (`tokensave serve` on the PC,
  `serve-tokensave` on g) from a folder with no index. Expect `"result"` with
  `serverInfo.version` = the new version.
