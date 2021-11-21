#!/bin/sh
# renaming - media file renaming script
# Copyright (C) 2021 FearlessDoggo21
# see LICENCE file for licensing information

lowerfex() {
	echo $(echo $1 | rev | cut -d. -f1 | rev) | tr '[:upper:]' '[:lower:]'
}

# same is the same folder counter
# past is the filename of the last non-same file
SAME=1
PAST="tmp" # same is not permitted on the first file
PASTVAL="tmpVAL" # unnecessary, for readability and simplicity

for FILE in $(ls); do
	vlc $FILE 2> /dev/null
	read -r NAME

	if [ "$NAME" = "del" ]; then
		mkdir -p del
		mv -i $FILE "del/$FILE"
		echo -e "$FILE >> del/$FILE\n"
		continue
	fi

	if [ "$NAME" = "same" ]; then
		# past blank if same folder already made
		if [ "$PAST" = "" ]; then
			mv -i $FILE "same$SAME"
			echo -e "$FILE >> same$SAME/$FILE\n"
		else
			mkdir "same$SAME"
			mv -i $PAST $FILE "same$SAME"
			eval "${PASTVAL}=\$(( ${PASTVAL}-1 ))" # correct var number

			echo "mkdir same$SAME"
			echo -e "$PAST $FILE >> same$SAME\n"
			PAST=""
		fi
		continue
	fi

	if [ "$(echo $NAME | cut -c-4)" = "same" ]; then
		mv -i $FILE "same$(echo $NAME | cut -c5-)"
		echo -e "$FILE >> same$(echo $NAME | cut -c5-)/$FILE\n"
		continue
	fi

	# if past is empty and we made it through same, new same folder number
	if [ "$PAST" = "" ]; then
		SAME=$(( $SAME+1 ))
	fi
	
	# add one to the counter for the current filename
	PASTVAL=${NAME}VAL
	eval "${PASTVAL}=\$(( ${PASTVAL}+1 ))"

	# set past equal to the filename
	eval "PAST=\"\$NAME\$$PASTVAL.\$(lowerfex \$FILE)\""
	mv -i $FILE $PAST

	echo -e "$FILE >> $PAST\n"
done
