#!/bin/bash

# sqpnetapply v1.00 (27th January 2014) by Heiko Steinwender
# Executed by JogglerSetupTZ - only used on SqueezePlay OS
# /opt/squeezeplay/bin/sqp_JogglerSetupTZ.sh

DEBUG=0

if  [ "$1" == "current" ]; then
	CURRENTZONE=`cat /etc/timezone 2>&1`
	if [ "$CURRENTZONE" != "" ]; then
		echo -n "$CURRENTZONE"
	else
		echo -n "Not set."
	fi
	exit 0

elif [ "$1" == "apply" ]; then
	echo "$2" | sudo tee /etc/timezone 2>&1
	sleep 1
	# sudo save settings
	CURRENTZONE=`sudo dpkg-reconfigure --frontend noninteractive tzdata 2>&1 | awk -F"'" '{print $2}'`
	if [ "$CURRENTZONE" != "" ]; then
		echo -n "$CURRENTZONE"
	else
		echo -n "Not set."
	fi
	exit 0
	
else
	echo -n "I've got nothing to do."
	exit 0
fi
