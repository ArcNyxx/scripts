#!/bin/sh
# sx - xorg client-server frontend
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

clean() {
	if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
		kill "$PID"; wait "$PID"
		EXIT=$?
	fi

	stty "$SAVE" || stty sane # if save fails, reset to default
	xauth remove ":$TTY"
	exit "${EXIT:-0}"
}

TTY="$(tty)"
SAVE="$(stty -g)"
if [ "${TTY#/dev/tty}" = "$TTY" ]; then
	echo "sx: unable to run from $TTY" >&2; exit 1
else
	TTY="${TTY#/dev/tty}"
fi

xauth add ":$TTY" . "$(od -An -N16 -x /dev/urandom | tr -d ' ')"
trap clean EXIT HUP INT TERM QUIT

# ignore SIGUSR1 in subshell, sending to external trap
trap 'DISPLAY=":$TTY" exec "$XINITRC" $@ & wait $!' USR1
(trap '' USR1 && exec Xorg ":$TTY" "vt$TTY" -keeptty -noreset \
	-auth "$XAUTHORITY") & PID=$!
wait "$PID" # clean
