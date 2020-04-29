#!/usr/bin/env bash

# openframe_timezone v1.00 (29th April 2020) by Andrew Davison
#  Now a basic handler for the of-timezone script.

THISSCRIPTPATH="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"

if [[ "$1" == "check" ]]; then

	timedatectl status | grep "Time zone" | awk -F\  {'print $3'}
	exit 0

elif [[ "$1" == "set" ]]; then

	if [ "$#" -eq 2 ]; then
		/usr/local/sbin/of-timezone "$1" "$2"
		exit 0
	else
		echo "Usage: $0 set <timezone>"
		exit 1
	fi

elif [[ "$1" == "update" ]]; then

	if [ "$#" -eq 2 ]; then
		/usr/local/sbin/of-timezone "$1" "$2"
		exit 0
	else
		SQPVER="squeezeplay-$(cat $THISSCRIPTPATH/../share/squeezeplay.version)-$(cat $THISSCRIPTPATH/../share/squeezeplay.revision)"
		/usr/local/sbin/of-timezone "$1" "$SQPVER"
		exit 0
	fi

fi

exit 0
