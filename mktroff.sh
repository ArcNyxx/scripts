#!/bin/sh
# mktroff - compile troff documents to pdf
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

if [ $? -eq 0 ]; then
	echo 'usage: mktroff [flag...] [file...]' >&2
	exit 1
fi

FLAGS=
INPUT=
for PARAM in $@; do
	if [ -z "${PARAM%-*}" ]; then
		FLAGS="$FLAGS $PARAM"
	else
		INPUT="$INPUT $PARAM"
	fi
done

LPATH='/usr/local/ucb'
"$LPATH/tbl" $INPUT | "$LPATH/eqn" | "$LPATH/troff" $FLAGS | "$LPATH/dpost" | ps2pdf - > mkout.pdf
if [ $? -eq 0 ]; then
	echo 'mktroff: output written to mkout.pdf' >&2
else
	echo 'mktroff: unable to write output' >&2
	exit $?
fi
