#!/usr/bin/env bash

##
## This script is a basic startup script for the SqueezePlay binary (jive) that requires a few environment variables be set.
##

## Change these if you changed your install path
INSTALL_DIR=/opt/squeezeplay
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
		 echo "Initial run, setting master audio output to full."
		/usr/bin/amixer -q -c 0 set "Master" 100% unmute
	fi

	if [ $OPENFRAME -eq 1 ]; then
		/usr/bin/amixer -q -c 0 set "Auto-Mute Mode" "Line Out+Speaker" &>/dev/null
	fi

	if [ $OPENFRAME -eq 2 ]; then
		/usr/bin/amixer -q -c 0 set "Auto-Mute Mode" "Enabled" &>/dev/null
		/usr/bin/amixer -q -c 0 set "Loopback Mixing" "Enabled" &>/dev/null
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
