#!/bin/sh
# ghlang - github repository languages
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

. /usr/local/etc/error.sh

[ $# -ne 1 ] && error 'usage: ghlang [name]'

TEMP=$(mktemp -dt)
trap "rm -rf $TEMP" EXIT

PAGE='1'; AUTH="${GHTOKEN:+--oauth2-bearer "$GHTOKEN"}"
while true; do
	URL="https://api.github.com/users/$1/repos?per_page=100&page=$PAGE"
	curl -s $AUTH "$URL" | grep '^    "name":' | cut '-d"' -f4
	[ "$(echo "$REPOS" | wc -w)" -ne "$((PAGE * 100))" ] && break
	PAGE=$((PAGE + 1))
done | while read -r REPO; do
	URL="https://api.github.com/repos/$1/$REPO/languages"
	curl -s $AUTH "$URL" | grep '^  ' | tr -d ' ",' | while read -r IN; do
		VALUE="$(cat "$TEMP/${IN%:*}" 2>/dev/null)"
		echo $((VALUE + ${IN#*:})) >"$TEMP/${IN%:*}"
	done
done

ls "$TEMP" | while read -r LANG; do
	echo "$(cat "$TEMP/$LANG") $LANG:"
done | sort - -gr | awk '{ print $2 $1 }'
