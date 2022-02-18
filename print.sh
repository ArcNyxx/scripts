#!/bin/sh
# print - functions for building troff docs, printing from remote cups servers
# Copyright (C) 2022 FearlessDoggo21
# see LICENCE file for licensing information

mktroff() {
	if [ "$1" = '-h' -o "$1" = '--help' -o "$#" -eq 0 ]; then
		echo 'mktroff: usage:  mktroff [flag...] [file...]'
		return
	fi

	FLAGS=
	INPUT=
	for PARAM in "$@"; do
		if [ "$(echo "$PARAM" | cut -c1-1)" = '-' ]; then
			FLAGS="$FLAGS $PARAM"
		else
			INPUT="$INPUT $PARAM"
		fi
	done

	# multiple forms of troff may exist, select desired version
	# lack of quotes on input intentional, used for multiple file input
	LPATH='/usr/local/ucb'
	"$LPATH/tbl" $INPUT | "$LPATH/eqn" | "$LPATH/troff" $FLAGS | \
		"$LPATH/dpost" | ps2pdf - > 'mkout.pdf' && \
		echo 'mktroff: status: output written to mkout.pdf'
}

print() {
	if [ "$1" = '-h' -o "$1" = '--help' -o "$#" -eq 0 ]; then
		echo 'print: usage:  print [file] [host] [copy] [options]'
		return
	fi

	FILE="$1"
	HOST="$2"
	DEST="$3"
	OPTS="-o media=Letter $4"

	[ -z "$HOST" ] && HOST="$REMOTE"
	[ -z "$DEST" ] && DEST='/home/pi/print'

	ssh -q "$HOST" "mkdir -p $DEST" 2> /dev/null
	if [ "$?" -eq 255 ]; then
		echo "print: error:  unable to connect to $HOST"
		return
	fi
	echo "print: status: created folder $DEST"

	scp "$FILE" "$HOST:$DEST" > /dev/null
	if [ "$?" -ne 0 ]; then
		echo "print: error:  unable to transfer $FILE to $DEST"
		return
	fi
	echo "print: status: $FILE transferred to $DEST"

	REQ=$(ssh -q "$HOST" "lp $OPTS $DEST/$(basename $FILE)" 2> /dev/null)
	echo "print: status: request id $(echo "$REQ" | cut '-d ' -f4)"
}

pstat() {
	if [ "$1" = '-h' -o "$1" = '--help' ]; then
		echo 'pstat: usage:  pstat [host]'
		return
	fi

	HOST="$1"

	[ -z "$HOST" ] && HOST="$REMOTE"

	ssh -q "$HOST" 'lpstat' 2> /dev/null | awk '{
		printf "pstat: status: request id " $1 " sent at ";
		for (i = 4; i <= NF; i++)
			str = str $i " ";
		system("date --date=\"" str "\" \"+%T on %A, %B %d\"")
	}'
}

pcanc() {
	if [ "$1" = '-h' -o "$1" = '--help' ]; then
		echo 'pcanc: usage:  pcanc [opts] [host]'
		return
	fi

	OPTS="$1"
	HOST="$2"

	[ -z "$OPTS" ] && OPTS="-a" && \
		echo 'pcanc: status: cancelling all requests'
	[ -z "$HOST" ] && HOST="$REMOTE"

	ssh -q "$HOST" "cancel $OPTS" 2> /dev/null
	if [ "$?" -ne 0 ]; then
		echo "pcanc: error:  unable to cancel requests"
		return
	fi
	echo "pcanc: status: cancelled requests"
}
