#!/bin/sh
# print - remotely print documents
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

. /usr/local/etc/error.sh

[ $# -eq 0 ] && error 'usage: print [cmd] [opt...]'

case "$1" in
	stat)
		ssh -q "$REMOTE" 'lpstat' 2>/dev/null | awk '{
			printf "pstat: request id " $1 " sent at ";
			for (i = 4; i <= NF; i++)
				str = str $i " ";
			system("date --date=\"" str "\" \"+%T on %A, %B %d\"")
		}'
		;;
	cancel)
		REQ="$2"
		[ -z "$REQ" ] && REQ='-a'

		ssh -q "$REMOTE" "cancel $REQ" 2>/dev/null
		[ $? -ne 0 ] && error 'print: unable to cancel requests' $?
		echo 'print: requests cancelled' >&2
		;;
	*.pdf)
		ssh -q "$REMOTE" "mkdir -p $PRDEST" 2>/dev/null
		[ $? -ne 0 ] && error "print: unable to mkdir $PRDEST" $?

		scp "$FILE" "$REMOTE:$PRDEST" >/dev/null
		[ $? -ne 0 ] && error 'print: unable to transfer document' $?
		echo "print: document transferred to $PRDEST/$1" >&2

		REQ="$(ssh -q "$REMOTE" "lp -o media=Letter $PRDEST/$(basename
			"$FILE")" 2>/dev/null | cut '-d ' -f4)"
		[ $? -ne 0 ] && error 'print: unable to print document' $?
		echo "print: printing with request id $REQ" >&2
		;;
esac
