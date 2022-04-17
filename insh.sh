#!/bin/sh
# insh - install script
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

[ -z "$1" ] && exit 1

FILE="${1%.*}"
cp "$1" "/usr/local/bin/${FILE%%*/}"
