#!/bin/sh
# mktroff - compile troff
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

if [ $# -eq 0 ]; then
	echo 'usage: mktroff [flag...] [file...]' >&2; exit 1
fi

unset FLAGS INPUT
for PARAM in $@; do
	if [ -z "${PARAM%-*}" ]; then
		FLAGS="$FLAGS $PARAM"
	else
		INPUT="$INPUT $PARAM"
	fi
done

PATH="/usr/local/ucb:$PATH"
tbl $INPUT | eqn | troff $FLAGS | dpost | ps2pdf - >mkout.pdf
[ $? -eq 0 ] && echo 'mktroff: output written to mkout.pdf' >&2
