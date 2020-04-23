#!/usr/bin/env bash

## builder-openframe.sh v1.02 (24th April 2020)
##  Automating builds of SqueezePlay for OpenFrame.

if [ "$(ls -di /)" == "2 /" ]; then
	echo "You need to run me from a 32-bit chroot."
	exit 1
fi

## Configure your location here
SQPGITLOC="/home/andy/Public/download_blw/github"
SQPLOGLOC="/home/andy/Public/download_blw/logs"
##

GITPULLRESULT=$(git -C "$SQPGITLOC/squeezeplay" pull)
LATESTREVISION=$(cat $SQPGITLOC/squeezeplay/src/squeezeplay.revision)
LOGFILE="$SQPLOGLOC/squeezeplay_$(date +'%Y-%m-%d-%H%M').txt"
THISSCRIPTPATH="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"

buildIt() {
	cd $SQPGITLOC/squeezeplay/src
	make -f Makefile.openframe &>> $LOGFILE
	echo >> $LOGFILE
	echo "$(date  +'%Y-%m-%d %H:%M:%S'): Build complete." >> $LOGFILE
}

if [[ "${1}" == "force" ]]; then

	echo "$(date  +'%Y-%m-%d %H:%M:%S'): Revision $LATESTREVISION build forced." > $LOGFILE
	echo >> $LOGFILE
	buildIt

elif [ ! -d $SQPLOGLOC/squeezeplay/build ]; then

	echo "$(date  +'%Y-%m-%d %H:%M:%S'): Revision $LATESTREVISION build from scratch." > $LOGFILE
	echo >> $LOGFILE
	buildIt

elif [ -d $SQPLOGLOC/squeezeplay/build ]; then

	HIGHESTBUILD=$(ls -1 $SQPGITLOC/squeezeplay/build/squeezeplay-*.tgz | tail -1 | awk -F'-' {'print $3'} | awk -F'.' {'print $1'})

	[[ "$HIGHESTBUILD" == "" ]] && HIGHESTBUILD="not having a build at all"

	if [[ $HIGHESTBUILD -lt $LATESTREVISION ]]; then

		echo "$(date  +'%Y-%m-%d %H:%M:%S'): Revision $LATESTREVISION supercedes $HIGHESTBUILD. Compiling." > $LOGFILE
		echo >> $LOGFILE
		buildIt

	else

		echo "$(date  +'%Y-%m-%d %H:%M:%S'): Revision $HIGHESTBUILD already built." > $LOGFILE

	fi

else

	buildIt

fi

exit 0
