#!/usr/bin/env bash

# openframe_update.sh v1.18 (29th April 2020) by Andrew Davison
#  Called by the OpenFrameUpdate applet to check for and install updates and return changelog.

if [ $# -eq 0 ] || [ $# -gt 2 ]; then
	echo "Usage: $0 <option>"
	echo
	echo "  installed:    :  Returns the version of SqueezePlay currently installed."
	echo "  check         :  Returns the version of SqueezePlay currently available."
	echo "  update        :  Installs the latest update."
	echo "  change <ver>  :  Fetches the changelog, up to the currently installed version."
	exit 1
fi

## Configurables
SERVER="openbeak.net"
SERVICE="/update/squeezeplay.php"
##

# This script should live in the squeezeplay/bin directory.
THISSCRIPTPATH="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"

# Get the currently installed version.
VERIN=$(cat $THISSCRIPTPATH/../share/squeezeplay.version)
REVIN=$(cat $THISSCRIPTPATH/../share/squeezeplay.revision)
[[ "$1" == "installed" ]] && echo "$VERIN-$REVIN" && exit 0


updateCheck() {

	# Build our user agent and request.
	UPANDLOAD="$(awk -F. {'print $1'} /proc/uptime)"/"$(awk '{$NF=""; print $0}' /proc/loadavg | awk '{$1=$1};1' | sed -e 's/\//-/g' -e 's/ /\//g')"
	USER_AGENT="$(cat /tmp/openframe.uid)"/"$(cat /tmp/openframe.net)"/"$(cat /tmp/openframe.nfo)"/"$(cat /tmp/openframe.ver)"/"$UPANDLOAD"
	[[ "${1}" == "force" ]] && REVIN="0000"

	# Before we send anything, test the validity of the URL with a plain curl request.
	TEST_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" https://$SERVER$SERVICE)
	[[ "$TEST_RESPONSE" == "200" ]] && SERVICE_RESPONSE=$(/usr/bin/curl -fsSA "$USER_AGENT" "https://$SERVER$SERVICE?ver=$VERIN-$REVIN" 2>&1) || SERVICE_RESPONSE="$TEST_RESPONSE"

}


if [[ "$1" == "check" ]]; then
	updateCheck "$2"
	if [[ "${SERVICE_RESPONSE:0:8}" == "https://" ]]; then
		VERUP=$(echo ${SERVICE_RESPONSE##*/} | awk -F'squeezeplay-' {'print $2'} | awk -F'.tgz' {'print $1'})
		echo $VERUP
	else
		echo "$SERVICE_RESPONSE"
	fi 
	exit 0
fi


if [[ "$1" == "update" ]]; then
	updateCheck "$2"
	if [[ "${SERVICE_RESPONSE:0:8}" == "https://" ]]; then

		VERUP=$(echo ${SERVICE_RESPONSE##*/} | awk -F'squeezeplay-' {'print $2'})
		echo
		wget -P /tmp "$SERVICE_RESPONSE"
		wget -P /tmp "$SERVICE_RESPONSE.md5"

		TGZHASH=$(cat /tmp/squeezeplay-$VERUP.md5 | awk -F' ' {'print $1'})
		OURHASH=$(md5sum /tmp/squeezeplay-$VERUP | awk -F' ' {'print $1'})

		if [[ "$OURHASH" != "$TGZHASH" ]]; then

			echo "Checksum mismatch. Bailing!"

		else

			[[ "$USER" == "squeezeplay" ]] && SUDOSQP="" || SUDOSQP="sudo -u squeezeplay"
			$SUDOSQP rm -rvf /opt/squeezeplay/*
			$SUDOSQP tar -C /opt/squeezeplay -zxvf /tmp/squeezeplay-$VERUP
			rm /tmp/squeezeplay-*.tgz*
			sync

		fi

	else

		# We're in the update loop on SqueezePlay now, so just reboot the thing.
		echo "$SERVICE_RESPONSE"
		sleep 3

	fi 

	[[ "$USER" == "squeezeplay" ]] && systemctl reboot -i

fi

exit 0
