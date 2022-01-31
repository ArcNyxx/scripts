#!/bin/sh
# ghlang - get github repository languages
# Copyright (C) 2022 FearlessDoggo21
# see LICENCE file for licensing information

[ -z "$NAME" ] && echo "ghlang: set \$NAME to github username" && exit 1

AUTH="-H \"Authorization: token $TOKEN\""
[ -z "$TOKEN" ] && AUTH=""

TEMP=$(mktemp -dt)
trap "rm -rf $TEMP" EXIT

while read -r REPO; do
	URL="https://api.github.com/repos/${NAME}/${REPO}/languages"
	curl "$URL" $AUTH 2> /dev/null | grep '^  ' | tr -d ':,' |
		while read -r LANG; do
			DATA=$(echo "$LANG" | cut '-d ' -f2)
			LANG=$(echo "$LANG" | cut '-d ' -f1 | cut '-d"' -f2)

			# no handling for lack of file, just equal to 0
			VALUE=$(cat "$TEMP/$LANG" 2> /dev/null)
			echo $((VALUE + "$DATA")) > "$TEMP/$LANG"
		done
done

ls "$TEMP" | while read -r LANG; do
	echo "$(cat "$TEMP/$LANG") $LANG:"
done | sort - -gr | awk '{ print $2 $1 }'
