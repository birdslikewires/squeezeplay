#!/usr/bin/env bash

## squeezeplay.sh v2.02 (20th April 2020)
##  Identifies which OpenFrame device we're running on and applies some tweaks.

[ -f /etc/lsb-release ] && source /etc/lsb-release

## Change this if you changed your install path
INSTALL_DIR=/opt/squeezeplay

## Change this to alter timezone server path
SERVER="openbeak.net"
SERVICE="/tz/lookup.php"

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

timezoneSet() {
	if [ -e /tmp/openframe.uid ] && [ -e /tmp/openframe.net ]; then
		SYS_TYP=$(cat /tmp/openframe.uid)/$(cat /tmp/openframe.net)/$(echo ${DISTRIB_DESCRIPTION,,} | awk -F' ' '{print $1 "/" $2}')/${DISTRIB_CODENAME,,}/$(uname -r)/squeezeplay-$(cat $INSTALL_DIR/share/squeezeplay.version)-$(cat $INSTALL_DIR/share/squeezeplay.revision)
	elif [ -f /etc/lsb-release ]; then
		SYS_TYP="///$(hostname)/$(echo ${DISTRIB_DESCRIPTION,,} | awk -F' ' '{print $1 "/" $2}')/${DISTRIB_CODENAME,,}/$(uname -r)/squeezeplay-$(cat $INSTALL_DIR/share/squeezeplay.version)-$(cat $INSTALL_DIR/share/squeezeplay.revision)"
	else
		SYS_TYP="///$(hostname)////$(uname -r)/squeezeplay-$(cat $INSTALL_DIR/share/squeezeplay.version)-$(cat $INSTALL_DIR/share/squeezeplay.revision)"
	fi
	echo -n "Setting timezone..."
	TIMEZONE=$(curl -sA "$SYS_TYP" -m 2 "https://$SERVER/$SERVICE")
	TIMEZONEVALID=$(echo $TIMEZONE | grep -c '/')
	if [[ "$TIMEZONE" != "" ]] && [[ "${#TIMEZONE}" -ge 6 ]] && [[ "${#TIMEZONE}" -le 32 ]] && [[ "$TIMEZONEVALID" -le 2 ]]; then
		echo -n " found $TIMEZONE..."
		sudo /usr/bin/timedatectl set-timezone $TIMEZONE
		echo " done."
	else
		echo " lookup failed... retaining $(timedatectl status | grep "Time zone" | awk -F\  {'print $3'})."
	fi
}

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

		timezoneSet

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
