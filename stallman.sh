#!/bin/sh
# stallman - non-free package detector
# Copyright (C) 2021 FearlessDoggo21
# see LICENCE file for licensing information

# urls to plaintext files
BLACKLISTS="https://git.parabola.nu/blacklist.git/plain/blacklist.txt
        https://git.parabola.nu/blacklist.git/plain/aur-blacklist.txt"
CACHE="$HOME/.cache/stallman/blacklist.txt"

# if the cache doesn't exist, create it and get the blacklist
[ ! -f $CACHE ] && \
        mkdir -p $(echo $CACHE | rev | cut -d/ -f2- | rev) && \
	curl -s $BLACKLISTS > $CACHE

for PACK in $(pacman -Qq); do
	grep "^$PACK:" $CACHE
done
