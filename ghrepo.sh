#!/bin/sh
# ghrepo - get github repositories
# Copyright (C) 2022 FearlessDoggo21
# see LICENCE file for licensing information

[ -z "$NAME" ] && echo "ghrepo: set \$NAME to github username" && exit 1

AUTH="-H \"Authorization: token $TOKEN\""
[ -z "$TOKEN" ] && AUTH=""

PAGE="1"
while true; do
	URL="https://api.github.com/users/${NAME}/repos?per_page=100&page=${PAGE}"
	REPO=$(curl "$URL" $AUTH 2> /dev/null |
		grep '^    "name":' | cut '-d"' -f4)

	echo "$REPO"
	[ $(echo "$REPO" | wc -l) -ne 100 ] && break
	PAGE=$((PAGE + 1))
done
