#!/bin/sh
# view - view pdf
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

FILE="${1:-mkout.pdf}"
if [ ! -f "$FILE" ]; then
	echo "view: unable to view $FILE" >&2; exit 1
fi

TIME="$(stat -c '%Y' "$FILE")"
mupdf "${1:-mkout.pdf}" & PROC=$!

while kill -0 "$PROC" >/dev/null 2>&1; do
	sleep 2
	[ ! -f "$FILE" ] && continue

	NTIME="$(stat -c '%Y' "$FILE")"
	[ "$TIME" != "$NTIME" ] && kill -1 "$PROC"
	TIME="$NTIME"
done &
