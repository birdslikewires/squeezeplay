#!/usr/bin/env bash

## squeezeplay.sh v2.03 (20th April 2020)
##  Identifies which OpenFrame device we're running on and applies some tweaks.

[ -f /etc/lsb-release ] && source /etc/lsb-release

## Change this if you changed your install path
INSTALL_DIR=/opt/squeezeplay
##

LIB_DIR=$INSTALL_DIR/lib
INC_DIR=$INSTALL_DIR/include

## Start up
export LD_LIBRARY_PATH=$LIB_DIR:$LD_LIBRARY_PATH
export LD_INCLUDE_PATH=$INC_DIR:$LD_INCLUDE_PATH
export PATH=$PATH:$INSTALL_DIR/bin:/usr/sbin
export PATH=$PATH:$INSTALL_DIR/bin

export DISPLAY=:0.0
export SDL_AUDIODRIVER=alsa
export SDL_VIDEO_WINDOW_POS=0,0
export SDL_VIDEO_ALLOW_SCREENSAVER=1
export KMP_DUPLICATE_LIB_OK=TRUE

if [ -e /tmp/openframe.ver ]; then

	OPENFRAME=`cat /tmp/openframe.ver`

	if [ ! -d /home/$USER/.squeezeplay ]; then

		echo -n "Setting master audio output to full..."
		/usr/bin/amixer -q -c 0 set "Master" 100% unmute
		echo " done."

		if [ $OPENFRAME -eq 1 ]; then
			echo -n "Enabling auto-mute switching..."
			/usr/bin/amixer -q -c 0 set "Auto-Mute Mode" "Line Out+Speaker" &>/dev/null
			echo " done."
		fi

		if [ $OPENFRAME -eq 2 ]; then
			echo -n "Enabling auto-mute switching..."
			/usr/bin/amixer -q -c 0 set "Auto-Mute Mode" "Enabled" &>/dev/null
			/usr/bin/amixer -q -c 0 set "Loopback Mixing" "Enabled" &>/dev/null
			echo " done."
		fi

		TIMEZONE=$($INSTALL_DIR/bin/openframe_timezone.sh update)
		echo "Setting time zone to $TIMEZONE... done."
		
	fi

	# killall shairport &>/dev/null

	# SHAIRPORTUP=""
	# SHAIRPORTUP=`ps aux | grep shairport.sh | grep -v grep`
	# if [ ${#SHAIRPORTUP} -eq 0 ]; then
	# 	[ -x $INSTALL_DIR/bin/shairport.sh ]
	# 	$INSTALL_DIR/bin/shairport.sh &
	# fi

	# HUH - why is this here?
 	#[ -x /usr/local/bin/shairport ] && $INSTALL_DIR/bin/sqp_JogglerFeatures.sh air start

fi

xset -display :0.0 dpms force on

cd $INSTALL_DIR/bin
./jive
