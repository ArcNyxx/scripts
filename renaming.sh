#!/bin/sh
# renaming - media file renaming script
# Copyright (C) 2021-2022 FearlessDoggo21
# see LICENCE file for licensing information

TEMP=$(mktemp -dt)
trap "rm -rf $TEMP" EXIT

PREFIX="."
[ "$#" -eq 1 ] && PREFIX="$1"
mkdir -p "$PREFIX/out"

PAST=""
CONT=""
DUPS=0

for FILE in $(ls -I "out" "$PREFIX"); do
	echo "$FILE"
	read -r NAME

	# deletion shortcut, move to deleted folder
	if [ "$NAME" = "" ]; then
		mkdir -p "$PREFIX/out/del"
		cp "$PREFIX/$FILE" "$PREFIX/out/del"
		echo -e "$PREFIX/$FILE >> $PREFIX/out/del/$FILE\n"
		continue
	fi

	# current duplicate shortcut, place in folder with others
	if [ "$NAME" = "dup" ]; then
		BASE=$(echo "$PAST" | rev | cut -d. -f2- | rev | tr -d '[:digit:]')

		if [ -n "$CONT" ]; then
			cp "$PREFIX/$FILE" "$PREFIX/out/dup$BASE$DUPS"
			echo -e "$PREFIX/$FILE >> $PREFIX/out/dup$BASE$DUPS/$FILE\n"
		else
			DUPS=$((DUPS + 1))
			CONT="y"

			# maintain number accuracy for later use of $PAST name
			VALUE=$(cat "$TEMP/$BASE" 2> /dev/null)
			echo $((VALUE - 1)) > "$TEMP/$BASE"

			# create a directory with the same name given to the file
			mkdir "$PREFIX/out/dup$BASE$DUPS"
			echo -e "mkdir $PREFIX/out/dup$BASE$DUPS"

			cp "$PREFIX/$FILE" "$PREFIX/out/dup$BASE$DUPS"
			mv "$PREFIX/out/$PAST" "$PREFIX/out/dup$BASE$DUPS"
			echo -e "$PREFIX/$FILE >> $PREFIX/out/dup$BASE$DUPS/$FILE"
			echo -e "$PREFIX/out/$PAST >> $PREFIX/out/dup$BASE$DUPS/$PAST\n"
		fi
		continue
	fi

	# combine the name with the lowercase extension and the number from the map
	VALUE=$(cat "$TEMP/$NAME" 2> /dev/null)
	VALUE=$((VALUE + 1))
	echo "$VALUE" > "$TEMP/$NAME"

	EXT=".$(echo "$FILE" | rev | cut -d. -f1 | rev | tr '[:upper:]' '[:lower:]')"
	[ "$(echo "$FILE" | cut -d. -f1)" = "$FILE" ] && EXT=""

	cp "$PREFIX/$FILE" "$PREFIX/out/$NAME$VALUE$EXT"
	echo -e "$PREFIX/$FILE >> $PREFIX/out/$NAME$VALUE$EXT\n"

	CONT=""
	PAST="$NAME$VALUE$EXT"
done
