#!/bin/sh
# print - remotely print documents
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

if [ $? -eq 0 ]; then
	echo 'usage: print [cmd] [opt...]' >&2
	exit 1
fi

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
		if [ $? -eq 0 ]; then
			echo 'print: requests cancelled' >&2
		else
			echo 'print: unable to cancel requests' >&2
			exit $?
		fi
		;;

	*.pdf)
		ssh -q "$REMOTE" "mkdir -p $PRDEST" 2>/dev/null
		if [ $? -ne 0 ]; then
			echo "print: unable to mkdir $PRDEST" >&2
			exit $?
		fi

		scp "$FILE" "$REMOTE:$PRDEST" >/dev/null
		if [ $? -eq 0 ]; then
			echo "print: document transferred to $PRPRDEST/$1" >&2
		else
			echo 'print: unable to transfer document' >&2
			exit $?
		fi

		REQ="$(ssh -q "$REMOTE" "lp -o media=Letter $PRDEST/$(basename "$FILE")" 2>/dev/null)"
		if [ $? -eq 0 ]; then
			echo "print: printing with request id $(echo "$REQ" | cut '-d ' -f4)" >&2
		else
			echo 'print: unable to print document' >&2
		fi
		;;
esac
