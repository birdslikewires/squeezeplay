#!/usr/bin/env bash

# openframe_power v1.11 (29th April 2020) by Andrew Davison
#  Executed by OpenFramePower applet.

if [ "$1" = "quit" ]; then

	/usr/bin/xset -display :0.0 dpms 0 0 0
	[ -e /tmp/of_initial_bl ] && /usr/local/sbin/of-backlight `cat /tmp/of_initial_bl` &

fi

if [ "$1" = "relaunch" ]; then

	sleep 2
	killall jive

fi

if [ "$1" = "reboot" ]; then
		
	sleep 2
	systemctl reboot -i

fi

if [ "$1" = "halt" ] || [ "$1" = "poweroff" ]; then

	sleep 2
	systemctl poweroff -i

fi

exit 0
