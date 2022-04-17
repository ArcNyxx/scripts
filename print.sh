#!/bin/sh
# print - remotely print documents
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

error() {
	echo $1 >&2; exit ${2:-1}
}

[ $# -eq 0 ] && error 'usage: print [cmd] [opt...]'
if [ "$1" = 'stat' ]; then
	ssh -q "$REMOTE" 'lpstat' 2>/dev/null | while read -r LINE; do
		echo -n "pstat: request id ${LINE%%\ *} sent at "
		date "--date=$(echo "$LINE" | tr -s ' ' | \ cut '-d ' -f4-)" \
			"+%T on %A, %B %d"
	done
elif [ "$1" = 'cancel' ]; then
	ssh -q "$REMOTE" "cancel ${2:--a}" 2>/dev/null
	[ $? -ne 0 ] && error 'print: unable to cancel requests' $?
	echo 'print: requests cancelled' >&2
else
	ssh -q "$REMOTE" "mkdir -p $PRDEST" 2>/dev/null
	[ $? -ne 0 ] && error "print: unable to mkdir $PRDEST" $?

	scp "$1" "$REMOTE:$PRDEST" >/dev/null
	[ $? -ne 0 ] && error 'print: unable to transfer document' $?
	echo "print: document transferred to $PRDEST/$1" >&2

	REQ="$(ssh -q "$REMOTE" "lp -o media=Letter $PRDEST/${1##*/}" \
		2>/dev/null)"
	[ $? -ne 0 ] && error 'print: unable to print document' $?
	echo "print: printing with request id ${REQ##* }" >&2
fi
