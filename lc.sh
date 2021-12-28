#!/bin/sh
# lc - line counter
# see LICENCE file for licensing information

if [ "$1" = "" ]; then
	FOLD="."
elif [ ! -d "$1" ]; then
	echo "lc: unable to open folder"
	exit
else
	FOLD="$1"
fi

BASE="" # the base dir to prepend to each subdir
EXTS="" # file extensions in use

# loops through all files, sorts out dirs beforehand, leaves labels
ls -ARp "$FOLD" | grep -v '/$' | while read -r FILE; do
	if [ "$BASE" = "" ]; then
		BASE="${FILE%:}/" # trims trailing colon, add slash
	elif [ "$FILE" = "" ]; then
		BASE="" # end of current dir contents
	else
		EXT=$(echo "$FILE" | rev | cut -d. -f1 | rev | tr '[:upper:]' '[:lower:]')
		echo $EXT

		if [ "$EXT" = "${EXT#* }" ] || [ "$EXT" = "$FILE" ] || [ "$EXT" = "" ]; then
			EXT="NONE" # ignore extensions with space or no extension
		fi

		# add to extension total then add extension to list if not present
		eval "echo EXT$EXT=\$((EXT$EXT + \$(wc -l \$BASE\$FILE | cut '-d ' -f1)))"
		if [ "${EXTS#*$EXT}" != "$EXTS" ]; then
			EXTS="$EXTS $EXT"
		fi
	fi
done

echo $EXTS

# loops through all extentions, printing totals into reverse numerical sort
for EXT in "$EXTS"; do
	eval "echo \${EXT}: \$EXT$EXT"
done | sort -nr
