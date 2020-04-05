#!/usr/bin/env bash

# openframe_asoundconf.sh v1.06 (4th April 2020) by Andrew Davison
#  Called by the OpenFrameAudioInterface applet to mess with the OpenFrame's audio settings.

if [[ "$1" = "" ]]; then
	echo "Usage: $0 <interface> <direct|shared>"
	exit 0
fi

asound_direct='pcm.!default {\n  type hw\n  card '${1}'\n}\n\nctl.!default {\n  type hw\n  card '${1}'\n}'

if [[ "${1}" == "0" ]]; then

	if [[ "${2}" == "direct" ]]; then
		echo -e $asound_direct > /home/$USER/.asoundrc
		echo "Set direct access to the internal interface."
	else
		[ -e /home/$USER/.asoundrc ] && rm /home/$USER/.asoundrc
		echo "Set shared access to the internal interface."
	fi

else

	if [[ "${2}" == "direct" ]]; then
		echo -e $asound_direct > /home/$USER/.asoundrc
		echo "Set direct access to the external interface."
	else
		sed 's/card 0/card '${1}'/g' /etc/asound.conf > /home/$USER/.asoundrc
		echo "Set shared access to the external interface."
	fi

fi

exit 0
