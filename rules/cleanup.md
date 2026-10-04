## MANDATORY: Clean up files AND processes before you finish

A task is not done while anything it started is still running or lying around. Leftovers from dead agents once kept 10 `grep -r` processes and 2 emulators busy for hours, and made the desktop slow.

- **Processes.** Stop every process, job, and service that you started: background commands, `nohup`/`&` jobs, emulators (qemu), dev servers, watchers, tunnels, `sleep` loops, long `find`/`grep -r` runs, and containers. Do this on every host you touched, also over ssh. Kill by PID that you recorded, or by an exact command-line match, never by a broad pattern that can hit the user's own programs.
- **Files.** Delete the scratch files, temp scripts, logs, and test output that you created, on every host (`/tmp`, scratch folders, copied scripts).
- **Before you report.** Run `ps` on each host you used and confirm that none of your processes remain. Say in the report what you stopped and deleted.
- **Keep.** Deliverables, backups of files you edited, and anything the user asked to keep. If you must leave something running on purpose (a service, a long build), name it, its PID, and how to stop it.
- **Unsure?** If you did not start it, do not kill it. Ask.
