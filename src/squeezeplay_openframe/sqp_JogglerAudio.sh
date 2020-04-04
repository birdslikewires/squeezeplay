#!/bin/sh

# sqp_JogglerAudio.sh v1.05 (25th July 2012) by Andy Davison
#  Called by the JogglerAudio applet to mess with the Joggler's audio settings.

PLATFORM=`cat /tmp/sqp_platform`
[ "$PLATFORM" = "native" ] || export PATH=$PATH:`dirname $0`

if [ "$1" = "" ]; then
	echo "Usage: $0 <option> <action>"
	exit 0
fi

if [ "$PLATFORM" = "native" ]; then
	INSTALL_DIR="/media/opt"
	SUDO=""
else
	INSTALL_DIR="/opt"
	SUDO="sudo"
fi


CRNTIFACE=`grep card /etc/asound.conf | head -1 | awk -F\card\  {'print $2'} | awk '{print substr($1,1,1)}'`


## Reset to defaults.
if [ "$1" = "reset" ]; then
	$SUDO cp /opt/squeezeplay/config/asound.conf_dmix /etc/asound.conf
	[ "$PLATFORM" = "sqpos" ] && amixer -c 0 set Master 24 unmute
	echo "Interface settings have been reset."
fi


## Enable or disable the audio output limiter.
if [ "$1" = "limiter" ]; then
	if [ "$2" = "disabled" ]; then
		if [ "$PLATFORM" = "sqpos" ]; then
			amixer -c 0 set Master 31 unmute
		elif [ "$PLATFORM" = "native" ]; then
			amixer -c 0 set Master 25 unmute
		else
			echo "Not a native or sqpOS system. Volume control is over to you!"
		fi
	else
		if [ "$PLATFORM" = "sqpos" ]; then
			amixer -c 0 set Master 24 unmute
		elif [ "$PLATFORM" = "native" ]; then
			echo "Volume limiting is baked-in on the native OS."
		else
			echo "Not a native or sqpOS system. Volume control is over to you!"
		fi
	fi
fi

## Set audio interface.
if [ "$1" = "iface" ]; then
	if [ "$2" = "" ]; then
		echo "Current interface is card $CRNTIFACE."
		exit 0
	elif [ "$2" = "$CRNTIFACE" ]; then
		echo "Interface is already correctly configured as card $CRNTIFACE."
		exit 0
	else
		if [ "$CRNTIFACE" = "0" ]; then
			$SUDO sed -i 's/card\ 0*/card\ 1/g' /etc/asound.conf
			$SUDO sed -i 's/pcm\ "hw:0*/pcm\ "hw:1/g' /etc/asound.conf	
		elif [ "$CRNTIFACE" = "1" ]; then
			$SUDO sed -i 's/card\ 1*/card\ 0/g' /etc/asound.conf
			$SUDO sed -i 's/pcm\ "hw:1*/pcm\ "hw:0/g' /etc/asound.conf
		fi
	fi
fi


## Swapping the asound.conf files.
if [ "$1" = "mixer" ]; then
	if [ "$2" = "" ]; then
		echo "Usage: $0 $1 <simple|mixer>"
		exit 0
	else
		if [ -f $INSTALL_DIR/squeezeplay/config/asound.conf_$2 ]; then
			$SUDO cp $INSTALL_DIR/squeezeplay/config/asound.conf_$2 /etc/asound.conf
			$0 iface $CRNTIFACE
		else
			echo "The asound.conf file 'config/asound.conf_$2' has not been found."
			exit 0
		fi
	fi
fi

exit 0