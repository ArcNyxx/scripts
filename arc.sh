#!/bin/sh
# arc - archive git repositories
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

recurse() {
	[ ! -d "${1:-.}" ] && return
	if [ "$(ls "${1:-.}/.git")" ]; then
		tar -cvzf "${1:-$PWD}.tar.gz" "${1:-.}"
	else
		ls "${1:-.}" | while read -r FOLD; do
			recurse "${1:-.}/$FOLD"
		done
	fi
}

recurse
