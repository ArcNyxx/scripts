#!/bin/sh
# reout - file renaming
# Copyright (C) 2021-2022 ArcNyxx
# see LICENCE file for licensing information

saywhat() {
	eval "$1 \"$2\" \"$3\""
	echo -e "$2 >> $3\n"
}

TEMP=$(mktemp -dt)
trap "rm -rf $TEMP" EXIT

PREFIX="."
[ $# -eq 1 ] && PREFIX="$1"
mkdir -p "$PRE/out/del"

PAST=''; CONT=''; DUPS=0
for FILE in $(ls -I out "$PRE"); do
	echo "reout: rename $FILE"
	read -r NAME
	NAME=$(echo "$NAME" | tr -d '[:digit:]')

	if [ -z "$NAME" ]; then
		saywhat "cp" "$PRE/$FILE" "$PRE/out/del"
	elif [ "$NAME" = "dup" ]; then
		BASE=$(echo "${PAST##*.}" | tr -d '[:digit:]')
		if [ -n "$CONT" ]; then
			saywhat "cp" "$PRE/$FILE" "$PRE/out/dup$BASE$DUPS"
		else
			DUPS=$((DUPS + 1))
			CONT='true'

			# maintain numerical accuracy for later use of $PAST
			VALUE=$(cat "$TEMP/$BASE" 2>/dev/null)
			VALUE=$((VALUE - 1))

			mkdir -p "$PRE/out/dup$BASE$DUPS"
			saywhat "cp" "$PRE/$FILE" "$PRE/out/dup$BASE$DUPS"
			saywhat "mv" "$PRE/out/$PAST" "$PRE/out/dup$BASE$DUPS"
		fi
	else
		# non-existent file returns 0
		VALUE=$(cat "$TEMP/$NAME" 2>/dev/null)
		VALUE=$((VALUE + 1))
		echo "$VALUE" > "$TEMP/$NAME"

		EXT=$(echo "${FILE##*.}" | tr '[:upper:]' '[:lower:]')
		[ "$EXT" = "$FILE" ] && EXT=""

		CONT=''
		PAST="$NAME$VALUE$EXT"
		saywhat "cp" "$PRE/$FILE" "$PRE/out/$PAST"
	fi
done
