#!/usr/bin/env bash

## openframe-builder.sh v1.00 (21st April 2020)
##  Builds SqueezePlay.

THISSCRIPTPATH="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"

GITPULLRESULT=$(git -C /var/www/birdslikewires/root/download/github/squeezeplay pull)

if [[ "$GITPULLRESULT" != "Already up to date." ]] || [[ "${1}" == "force" ]]; then

	/usr/bin/schroot -c bionic-i386 -- bash -c "cd $THISSCRIPTPATH; make -f Makefile.openframe &> /home/andy/Public/download_blw/openframe/logs/build/squeezeplay_`date +'\%Y-\%m-\%d-\%H\%M'`.txt"

fi

exit 0