## MANDATORY: Give changes as patches

When you show the user a change to a file, give it as a unified diff that the `patch` command applies. Do not give loose code lines or whole files.

- Make the diff with `diff -u` or `git diff`, so each hunk has context lines and a `@@` header.
- Give the command that applies it in the same block, for example `patch -p1 <<'EOF'` ... `EOF`, with the correct `-p` level and the path the user runs it from.
- For a file on another host, wrap it in one command: `ssh HOST 'cd DIR && patch -p1' <<'EOF'` ... `EOF`.
- Give a whole file only when the file is new or the user asks for the whole file.
- This rule is for changes you show the user. When you edit files yourself, use your edit tools as usual.
