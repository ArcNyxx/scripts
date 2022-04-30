#!/bin/sh
# view - view pdf
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

error() {
	echo "$1" >&2; exit 1
}

FILE="${1:-mkout.pdf}"
[ ! -f "$FILE" ] && error "view: unable to view $FILE"

TIME="$(stat -c '%Y' "$FILE" 2>/dev/null)"
mupdf "$FILE" & PROC=$!

while kill -0 "$PROC" >/dev/null 2>&1; do
	NTIME="$(stat -c '%Y' "$FILE" 2>/dev/null)"
	[ $? -ne 0 ] && error "view: unable to view $FILE"

	[ $((NTIME - TIME)) -ne 0 ] && kill -1 "$PROC"
	sleep 2
done &
