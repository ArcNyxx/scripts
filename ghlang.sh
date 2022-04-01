#!/bin/sh
# ghlang - github repository languages
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

if [ -z "$1" ]; then
	echo 'usage: ghlang [name]' >&2
	exit 1
fi

TEMP=$(mktemp -dt)
trap "rm -rf $TEMP" EXIT

AUTH="-H \"Authorization: token $GHTOKEN\""=
[ -z "$GHTOKEN" ] && AUTH=

PAGE='1'
while true; do
	URL="https://api.github.com/users/$1/repos?per_page=100&page=${PAGE}"
	REPOS="$(curl "$URL" $AUTH 2>/dev/null | grep '^    "name":' | cut '-d"' -f4) $REPOS"
	[ "$(echo "$REPOS" | wc -w)" != "$((PAGE * 100))" ] && break
	PAGE=$((PAGE + 1))
done

echo "$REPOS" | while read -r REPO; do
	URL="https://api.github.com/repos/${NAME}/${REPO}/languages"
	curl "$URL" $AUTH 2>/dev/null | grep '^  ' | tr -d ':,' | while read -r LANG; do
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
