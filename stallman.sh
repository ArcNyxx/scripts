#!/bin/sh
# stallman - non-free package detector
# Copyright (C) 2021 FearlessDoggo21
# see LICENCE file for licensing information

# urls to plaintext files
BLACKLISTS="https://git.parabola.nu/blacklist.git/plain/blacklist.txt
        https://git.parabola.nu/blacklist.git/plain/aur-blacklist.txt"
CACHE="$HOME/.cache/stallman/blacklist.txt"

if [ ! -f $CACHE ]; then
        mkdir -p $(echo $CACHE | rev | cut -d/ -f2- | rev)
        touch $(echo $CACHE | rev | cut -d/ -f1 | rev)
fi

PACKS=$(pacman -Qq)
STALL=

curl $BLACKLISTS > $CACHE
BLPACKS=$($(cat $CACHE) | tr '\n' '" "')

echo $BLPACKS
exit

for FBLPACK in $BLPACKS; do
        SBLPACK=$(echo $FBLPACK | cut -d: -f1)
        if echo $PACKS | grep $SBLPACH; then
                echo $FBLPACK
        fi
done
