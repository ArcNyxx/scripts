#!/bin/sh
# mktroff - compile troff documents to pdf
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

. /usr/local/etc/error.sh

[ $# -eq 0 ] && error 'usage: mktroff [flag...] [file...]'

FLAGS=''; INPUT=''
for PARAM in $@; do
	if [ -z "${PARAM%-*}" ]; then
		FLAGS="$FLAGS $PARAM"
	else
		INPUT="$INPUT $PARAM"
	fi
done

LPATH='/usr/local/ucb'
"$LPATH/tbl" $INPUT | "$LPATH/eqn" | "$LPATH/troff" $FLAGS | \
	"$LPATH/dpost" | ps2pdf - > mkout.pdf
[ $? -ne 0 ] && error 'mktroff: unable to write output' $?
echo 'mktroff: output written to mkout.pdf' >&2
