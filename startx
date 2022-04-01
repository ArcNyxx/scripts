#!/bin/sh
# startx - xinit frontend
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

[ -z "$XINITRC" ] && export XINITRC='/etc/X11/xinit/xinitrc'
[ -z "$XSERVERRC" ] && export XSERVERRC='/etc/X11/xinit/xserverrc'

# parse command line arguments similar to xinit, start with client args
CLIENT=1
while [ -n "$1" ]; do
	case "$1" in
	/*|\./*)
		# full path indicates different client
		[ "$CLIENT" = 1 ] && XINITRC="$1"
		[ "$CLIENT" = 0 ] && XSERVERRC="$1"
		;;
	--)
		CLIENT=0
		;;
	*)
		if [ "$CLIENT" = 1 ]; then
			XCLIENTARGS="$XCLIENTARGS $1"
		else
			if [ -z "$XSERVERARGS" ] && expr "$1" : \
				':[0-9][0-9]*$' > /dev/null 2>&1; then
				DISPLAY="$1"
			else
				XSERVERARGS="$XSERVERARGS $1"
			fi
		fi
		;;
	esac
	shift
done

# determine unused display (default 0)
# locks stored in /tmp in following formats:
#     .X[x]-lock      (file)
#     .X11-unix/X[x]  (socket)
# where [x] is locked display number
[ -z "$DISPLAY" ] && DISPLAY=0
while true; do
	[ -e "/tmp/.X$DISPLAY-lock" -o -S "/tmp/.X11-unix/X$DISPLAY" ] || \
		break
	DISPLAY=$((DISPLAY + 1))
done
DISPLAY=":$DISPLAY"

if [ -z "$XAUTHORITY" ]; then
	export XAUTHORITY="$HOME/.Xauthority"
fi

# create xauth magic cookie for user authentication
MCOOKIE="$(mcookie)"
if [ -z "$MCOOKIE" ]; then
	echo 'startx: unable to create mcookie'
	exit 1
fi

# create xauth server auth information, add credentials
XSERVERAUTH="$(mktemp -p /tmp xserverauth.XXXXXXXXXX)"
xauth -q -f "$XSERVERAUTH" add ':0' . $MCOOKIE

# add same credentials to client authority file
DUMMY=0
for NAME in "$DISPLAY" "$(uname -n)/unix$DISPLAY"; do
	COOKIE="$(xauth list "$NAME" | sed \
		"s/.*$(uname -n)\/unix$DISPLAY[[:space:]*].*[[:space:]*]//p")"
	if [ -z "$COOKIE" ]; then
		# add cookie to client file
		xauth -q add "$NAME" . "$MCOOKIE"
		RMLIST="$NAME $RMLIST"
	else
		# no overwrite, another server may need, add to server file
		DUMMY=$((DUMMY + 1))
		xauth -q -f "$XSERVERAUTH" add ":$DUMMY" . "$COOKIE"
	fi
done

# start server on current tty
if expr "$(tty)" : '/dev/tty[0-9][0-9]*$' > /dev/null; then
	XSERVERARGS="$XSERVERARGS vt$(tty | grep -oE '[0-9]+$') -keeptty"
fi

xinit "$XINITRC" $XCLIENTARGS -- "$XSERVERRC" "$DISPLAY" $XSERVERARGS
RETVAL=$?

[ -n "$RMLIST" ] && xauth remove "$RMLIST"
[ -n "$XSERVERAUTH" ] && rm -f "$XSERVERAUTH"

command -v deallocvt > /dev/null 2>&1 && deallocvt
exit $RETVAL
