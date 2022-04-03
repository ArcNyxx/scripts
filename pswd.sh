#!/bin/sh
# pswd - password manager
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

. /usr/local/etc/error.sh

# make "$PSWD" file if not exists
[ -z "$PSWD" ] && error 'pswd: $PSWD variable unset'
[ ! -e "$PSWD" ] && mkdir -p "${PSWD%/*}" && \
	touch "$PSWD" 2>/dev/null && age -p "$PSWD"
[ $? -ne 0 ] && error 'pswd: unable to make $PSWD file'

# read "$PSWD" file, output and exit if no arguments
READ="$(age -d "$PSWD" 2>/dev/null)"
[ $? -ne 0 ] && error 'pswd: unable to read $PSWD file'
[ -z "$1" ]  && error "$READ" 0

case "$1" in
	add)
		echo 'pswd: add: enter site, user, and pass' >&2
		read -r SITE; read -r USER; read -r PASS
		echo -e "$READ\n$SITE $USER $PASS" | sort -u | column -t | \
			age -e -p -o "$PSWD"
		;;
	rm)
		echo 'pswd: rm: enter site' >&2
		read -r SITE

		# verify line to remove
		GREP=$(echo "$READ" | grep "^$SITE" | column -t)
		LINC=$(echo "$GREP" | wc -l)

		if [ $LINC -eq 0 ]; then
			error "pswd: $SITE not found in \$PSWD"
		elif [ "$LINC" -ne 1 ]; then
			echo 'pswd: rm: select line to remove' >&2
			ITER=1
			echo "$GREP" | while read -r LINE; do
				OUT="$ITER" # pad line number
				while [ "${#OUT}" -le "$LC" ]; do
					OUT="0$OUT"
				done

				echo "($OUT) $LINE"
				ITER=$((ITER + 1))
			done

			read -r "$LINE"
			RM=$(echo "$GREP" | sed "${LINE}q;d")
			[ -z "$RM" ] && error "pswd: rm: $LINE not found"
			
			echo "pswd: rm: remove $RM? [y/N]" >&2
			read -r "$YES"
			[ "$YES" = 'y' ] && echo "$READ" | grep -v "$RM" | \
				sort -u | column -t | age -e -p -o "$PSWD"
		fi
		;;
esac
