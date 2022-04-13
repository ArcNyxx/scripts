#!/bin/sh
# print - remotely print documents
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

. /usr/local/etc/error.sh

[ $# -eq 0 ] && error 'usage: print [cmd] [opt...]'

case "$1" in
	stat)
		ssh -q "$REMOTE" 'lpstat' 2>/dev/null | while read -r LINE; do
			echo -n "pstat: request id ${LINE%%\ *} sent at "
			date "--date=$(echo "$LINE" | tr -s ' ' | \
				cut '-d ' -f4-)" "+%T on %A, %B %d"
		done
		;;
	cancel)
		REQ="$2"
		[ -z "$REQ" ] && REQ='-a'

		ssh -q "$REMOTE" "cancel $REQ" 2>/dev/null
		[ $? -ne 0 ] && error 'print: unable to cancel requests' $?
		echo 'print: requests cancelled' >&2
		;;
	*.pdf)
		ssh -q "$REMOTE" "mkdir -p $DEST" 2>/dev/null
		[ $? -ne 0 ] && error "print: unable to mkdir $DEST" $?

		scp "$1" "$REMOTE:$DEST" >/dev/null
		[ $? -ne 0 ] && error 'print: unable to transfer document' $?
		echo "print: document transferred to $DEST/$1" >&2

		REQ="$(ssh -q "$REMOTE" "lp -o media=Letter $DEST/$(basename \
			"$1")" 2>/dev/null | cut '-d ' -f4)"
		[ $? -ne 0 ] && error 'print: unable to print document' $?
		echo "print: printing with request id $REQ" >&2
		;;
	*)
		error 'usage: print [cmd] [opt...]'
		;;
esac
