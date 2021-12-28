#!/bin/sh
# mla pdftex - mla pdf text formatter
# Copyright (C) 2021 FearlessDoggo21
# see LICENCE file for licensing information

if [ "$#" -ne 2 ] || ! [ -e "$2" ]; then
	echo "usage: mla.pdftex.sh [file]" >&2
	exit 1
fi


