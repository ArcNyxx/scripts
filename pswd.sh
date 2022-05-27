#!/bin/sh
# pswd - password manager
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

error() {
	echo "$1" ; exit "${2:-1}"
}

[ -z "$PSWD" ] && error 'pswd: $PSWD variable unset'
if [ ! -f "$PSWD" ]; then
	mkdir -p "${PSWD%/*}" && touch "$PSWD" 2>/dev/null && age -p "$PSWD"
	[ $? -ne 0 ] && error 'pswd: unable to make $PSWD file'
fi

case "$1" in
	add)
		[ $# -ne 2 ] && error 'usage: pswd add [site]'
		echo 'pswd: enter your username and password' >&2
		read -r USER PASS
		READ="$(age -d "$PSWD" 2>/dev/null)"
		[ -z "$READ" ] && error 'pswd: unable to read $PSWD file'
		echo -e "$READ\n$2 $USER $PASS" | sort -u | column -t | \
			age -e -p -o "$PSWD"
		;;
	read)
		age -d "$PSWD" 2>/dev/null || error \
			'pswd: unable to read $PSWD file'
		;;
	remove)
		[ $# -ne 2 -a $# -ne 3 ] && error \
			'usage: pswd remove [site] [user]'
		READ="$(age -d "$PSWD" 2>/dev/null)"
		[ -z "$READ" ] && error 'pswd: unable to read $PSWD file'

		GREP="$(echo "$READ" | awk "/^$2/ ${3:+&& /  $3  /}")"
		[ "$(echo "$GREP" | wc -l)" -ne 1 ] && error \
			'pswd: only one line may be selected to remove'
		echo "$READ" | grep -v "$GREP" | sort -u | column -t | \
			age -e -p -o "$PSWD"
		;;
	backup)
		base64 "$PSWD" >"$PSWD.b64"
		;;
	*)
		error 'usage: pswd [cmd] ...'
esac
