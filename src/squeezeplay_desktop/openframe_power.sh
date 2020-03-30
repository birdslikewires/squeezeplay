#!/usr/bin/env bash

# openframe_power v1.10 (31st March 2020) by Andrew Davison
#  Executed by OpenFramePower and Quit applets.

if [ "$1" = "quit" ]; then

	/usr/bin/xset -display :0.0 dpms 0 0 0
	/usr/local/sbin/of-backlight `cat /tmp/sqp_initial_bl` &

fi

if [ "$1" = "relaunch" ]; then

	sleep 2
	killall jive

fi

if [ "$1" = "reboot" ]; then
		
	sleep 2
	sudo /sbin/reboot

fi

if [ "$1" = "halt" ] || [ "$1" = "poweroff" ]; then

	sleep 2
	sudo /sbin/poweroff

fi

exit 0
