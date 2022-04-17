#!/bin/sh
# xinitrc - xorg client
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

xrandr --output 'eDP-1'    --mode '1920x1080' \
       --output 'HDMI-1-1' --mode '1920x1080' --left-of 'eDP-1'
xwallpaper --zoom images/etc/wallpaper.png
xcompmgr -n &
while stext; do
	sleep 0.25
done &

[ $# -gt 0] && exec $@
exec swim
