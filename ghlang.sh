#!/bin/sh
# ghlang - github repository languages
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

if [ $# -ne 1 ]; then
	echo 'usage: ghlang [name]' >&2; exit 1
fi

TEMP=$(mktemp -dt)
trap "rm -rf $TEMP" EXIT

PAGE='1'; AUTH="${GHTOKEN:+--oauth2-bearer "$GHTOKEN"}"
while true; do
	URL="https://api.github.com/users/$1/repos?per_page=100&page=$PAGE"
	RE="$RE $(curl -s $AUTH "$URL" | grep '^    "name":' | cut '-d"' -f4)"

	[ "$(echo "$RE" | wc -w)" -ne "$((PAGE * 100))" ] && break
	PAGE=$((PAGE + 1))
done

echo "$RE" | while read -r REPO; do
	curl -s $AUTH "https://api.github.com/repos/$1/$REPO/languages" |
		grep '^  ' | tr -d ' ",' | while read -r IN; do
			VALUE="$(cat "$TEMP/${IN%:*}" 2>/dev/null)"
			echo $((VALUE + ${IN#*:})) >"$TEMP/${IN%:*}"
		done
done

ls "$TEMP" | while read -r LANG; do
	echo "$(cat "$TEMP/$LANG") $LANG:"
done | sort - -gr | awk '{ print $2 $1 }'
