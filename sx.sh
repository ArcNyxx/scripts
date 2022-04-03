#!/bin/sh
# sx - xorg client-server frontend
# Copyright (C) 2017 Earnestly
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

clean() {
	if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
		kill "$PID"; wait "$PID"
		EXIT=$?
	fi

	stty "$STTY" || stty sane # if saved fails, reset to default
	xauth remove ":$TTY"
	exit "${EXIT:-0}"
}

TTY="$(tty)"; TTY="${TTY#/dev/tty}"
STTY="$(stty -g)"

export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
xauth add ":$TTY" MIT-MAGIC-COOKIE-1 \
	"$(od -An -N16 -tx /dev/urandom | tr -d ' ')"

# clean on exit or interrupt
trap 'clean' EXIT HUP INT TERM QUIT

# xorg sends sigusr when ready to accept connections
trap 'DISPLAY=":$TTY" exec "$XINITRC" $@ & wait $!' USR1

# fork subshell to exec new server process
# ignore signal to allow handling from outside
# outside handles either due to xorg sending signal or trap not blocking
(trap '' USR1 && exec Xorg ":$TTY" -keeptty "vt$TTY" \
	-noreset -auth "$XAUTHORITY") & PID=$!
wait "$PID"
