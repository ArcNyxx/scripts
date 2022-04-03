#!/bin/sh
# stallman - non-free package detector
# Copyright (C) 2021 ArcNyxx
# see LICENCE file for licensing information

# urls to plaintext files
BLACKLISTS="https://git.parabola.nu/blacklist.git/plain/blacklist.txt
	https://git.parabola.nu/blacklist.git/plain/aur-blacklist.txt"
CACHE="$HOME/.cache/stallman/blacklist.txt"

[ ! -f $CACHE ] && mkdir -p "${CACHE%/*}" && curl -s $BLACKLISTS > $CACHE
for PACK in $(pacman -Qq); do
	grep "^$PACK:" $CACHE
done
