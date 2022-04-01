#!/bin/sh
# insh - install shell script
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

if [ -n "$1" ]; then
	FILE="${1%.*}"
	cp "$1" "/usr/local/bin/${FILE##*/}"
fi
