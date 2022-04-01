#!/bin/sh
# pswd - text file password manager
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

which age > /dev/null
if [ "$?" -ne 0 ]; then
	echo "pswd: unable to find age"
	exit 1
fi

case "$1" in
	new)
		mkdir -p "$(echo "${PSWD}pswd.age" | rev | cut -d/ -f2- | rev)"
		echo "pswd file - $(date +%0d-%0m-%y)" | \
			age -e -p -o "${PSWD}pswd.age"
		;;
	del)
		if [ ! -e "${PSWD}pswd.age" ]; then
			echo "pswd: file does not exist: ${PSWD}pswd.age"
			exit 1
		fi

		echo "pswd: confirm del file [y/N]"
		read -r CONFIRM
		
		if [ "$CONFIRM" != y ]; then
			echo "pswd: confirm fail"
			exit 0
		fi

		rm -f "${PSWD}pswd.age"
		;;

	add)
		if [ -z "$2" ]; then
			echo "pswd: add [line]"
			exit 1
		fi

		if [ ! -e "${PSWD}pswd.age" ]; then
			echo "pswd: file does not exist: ${PSWD}pswd.age"
			exit 1
		fi

		DATA="$(age -d "${PSWD}pswd.age")"
		if [ -z "$DATA" ]; then
			echo "pswd: unable to read passwords"
			exit 1
		fi

		echo -e "$DATA\n$2" | age -e -p -o "${PSWD}pswd.age"
		;;

	rm)
		if [ -z "$2" ]; then
			echo "pswd: rm [line]"
			exit 1
		fi

		if [ ! -e "${PSWD}pswd.age" ]; then
			echo "pswd: file does not exist: ${PSWD}pswd.age"
			exit 1
		fi

		DATA="$(age -d "${PSWD}pswd.age")"
		if [ -z "$DATA" ]; then
			echo "pswd: unable to read passwords"
			exit 1
		fi

		echo "$DATA" | grep "$2"
		echo "pswd: confirm del line [y/N]"
		read -r CONFIRM
		
		if [ "$CONFIRM" != y ]; then
			echo "pswd: confirm fail"
			exit 0
		fi

		echo "$DATA" | grep -v "$2" | age -e -p -o "${PSWD}pswd.age"
		;;

	read)
		if [ ! -e "${PSWD}pswd.age" ]; then
			echo "pswd: file does not exist: ${PSWD}pswd.age"
			exit 1
		fi

		age -d "${PSWD}pswd.age"
		;;

	*)
		echo "pswd: invalid command: $1"
		exit 1
		;;
esac
