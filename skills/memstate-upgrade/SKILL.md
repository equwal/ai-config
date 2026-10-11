---
name: memstate-upgrade
description: Upgrade jose's memstate install (memstated daemon, memstate CLI, memstate-mcp proxy, skills) on the PC, desktop g and the honjimaku daemon to the latest map588/memstate release. Use when the user says "update memstate", "memstated upgrade", or a newer memstate release is out.
---

# Upgrade memstate everywhere

Three places run memstate. Upgrade all three, then verify each.

## 1. PC (Windows)

1. Binaries. `MEMSTATE_ADDR` points at the honjimaku daemon, and `memstated upgrade`
   shuts down the daemon at that address. Always pass a local address:
   `memstated upgrade --addr 127.0.0.1:8765`
   Then copy `~/go/bin/memstated.exe` over `~/go/bin/memstate.exe` (same binary, the CLI
   dispatches on its name).
2. Proxy. The global npm package `@memstate/mcp` is a junction to
   `W:\src\memstate-main\client` (worktree of `C:\Users\Administrator\src\memstate`, branch main).
   `git -C W:/src/memstate-main fetch origin; git -C W:/src/memstate-main merge --ff-only origin/main`,
   then in `client/`: `npm ci; npm run build`.
   Never `npm install @memstate/mcp`: the npm registry package is another project.
3. Verify against the live daemon:
   `$env:MEMSTATE_ADDR='10.66.0.1:8767'; node W:/src/memstate-main/client/dist/index.js --test`
4. Skills. Copy `client/skill` and `client/skill-precompact` into `W:\src\ai-config\skills\memstate`
   and `skills\memstate-precompact`, and into the 5 PC skill folders
   (`~/.claude/skills`, `~/.codex/skills`, `~/.copilot/skills`, `~/.gemini/skills`,
   `~/.gemini/antigravity/skills`). Commit each repo. A new skill also needs a
   `[skills.<name>]` line in `acsync.toml`, or acsync on g does not render it.

## 2. Desktop g

g has no sftp and no wget. Stream scripts: `Get-Content -Raw f | ssh g 'tr -d "\r" | sh'`.
- `MEMSTATE_ADDR=127.0.0.1:1 ~/.local/bin/memstated upgrade --addr 127.0.0.1:1`
- Proxy: download `memstate-mcp.tar.gz` from the release with curl, move the old
  `~/.local/lib/node_modules/@memstate/mcp` into a `mktemp -d` dir, move the bundle's
  `client/` in its place, run `node .../dist/index.js --test` with a scratch `MEMSTATE_DB`.
- Skills: push ai-config to both remotes, then on g run
  `python3 ~/.local/share/acsync/agent-config-sync/acsync.py --repo ~/.local/share/acsync/ai-config sync`.

## 3. honjimaku daemon

`memstated.service`, binary `/opt/memstate/memstated`, DB `/var/lib/memstate`.
Stop the service, copy `memstate.db*` and the old binary into
`/var/lib/memstate/backups/pre-<version>-<timestamp>/`, install the release
`memstated-linux-amd64`, start, then check `memstate status` from the PC shows the
new version. This is a live shared service: it needs the user's yes.

## Push ai-config

`git push git@github.com:equwal/ai-config.git main` and
`git push --receive-pack='runuser -u aiconfig -- git-receive-pack' root@honjimaku.com:/srv/git/ai-config.git main`.
