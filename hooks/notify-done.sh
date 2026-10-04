#!/bin/sh
# Desktop notification on g (dwl/Wayland). Starts a private session bus + mako on demand.
# Usage: notify-done.sh [title] [message]
export PATH=$PATH:/bin:/usr/bin:/home/jose/.local/state/nix/profiles/extra/bin
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp}
BUS=/tmp/jose-notify-bus
export DBUS_SESSION_BUS_ADDRESS=unix:path=$BUS
# newest wayland socket belongs to the live dwl session
export WAYLAND_DISPLAY=$(ls -t /tmp/wayland-? 2>/dev/null | head -1 | sed 's|.*/||')
[ -S "$BUS" ] || { rm -f "$BUS"; DBD=$(ls /nix/store/*dbus-1.*/bin/dbus-daemon 2>/dev/null | head -1)
  [ -n "$DBD" ] && "$DBD" --config-file="$(dirname "$DBD")/../share/dbus-1/session.conf" --fork --address="$DBUS_SESSION_BUS_ADDRESS" >/dev/null 2>&1; }
pgrep -x mako >/dev/null || { nohup mako >/dev/null 2>&1 & sleep 1; }
notify-send "${1:-AI done}" "${2:-Turn finished}" 2>/dev/null
exit 0