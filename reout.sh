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







PAST=""
CONT=""
DUPS=0

for FILE in $(ls -I "out" "$PRE"); do
	echo "$FILE"
	read -r NAME

	# deletion shortcut, move to deleted folder
	if [ "$NAME" = "" ]; then
		mkdir -p "$PRE/out/del"
		cp "$PRE/$FILE" "$PRE/out/del"
		echo -e "$PRE/$FILE >> $PRE/out/del/$FILE\n"
		continue
	fi

	# current duplicate shortcut, place in folder with others
	if [ "$NAME" = "dup" ]; then
		BASE=$(echo "$PAST" | rev | cut -d. -f2- | rev | tr -d '[:digit:]')

		if [ -n "$CONT" ]; then
			cp "$PRE/$FILE" "$PRE/out/dup$BASE$DUPS"
			echo -e "$PRE/$FILE >> $PRE/out/dup$BASE$DUPS/$FILE\n"
		else
			DUPS=$((DUPS + 1))
			CONT="y"

			# maintain number accuracy for later use of $PAST name
			VALUE=$(cat "$TEMP/$BASE" 2> /dev/null)
			echo $((VALUE - 1)) > "$TEMP/$BASE"

			# create a directory with the same name given to the file
			mkdir "$PRE/out/dup$BASE$DUPS"
			echo -e "mkdir $PRE/out/dup$BASE$DUPS"

			cp "$PRE/$FILE" "$PRE/out/dup$BASE$DUPS"
			mv "$PRE/out/$PAST" "$PRE/out/dup$BASE$DUPS"
			echo -e "$PRE/$FILE >> $PRE/out/dup$BASE$DUPS/$FILE"
			echo -e "$PRE/out/$PAST >> $PRE/out/dup$BASE$DUPS/$PAST\n"
		fi
		continue
	fi

	# combine the name with the lowercase extension and the number from the map
	VALUE=$(cat "$TEMP/$NAME" 2> /dev/null)
	VALUE=$((VALUE + 1))
	echo "$VALUE" > "$TEMP/$NAME"

	EXT=".$(echo "$FILE" | rev | cut -d. -f1 | rev | tr '[:upper:]' '[:lower:]')"
	[ "$(echo "$FILE" | cut -d. -f1)" = "$FILE" ] && EXT=""

	cp "$PRE/$FILE" "$PRE/out/$NAME$VALUE$EXT"
	echo -e "$PRE/$FILE >> $PRE/out/$NAME$VALUE$EXT\n"

	CONT=""
	PAST="$NAME$VALUE$EXT"
done
