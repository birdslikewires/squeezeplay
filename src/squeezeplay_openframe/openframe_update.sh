#!/bin/sh

# sqp_JogglerUpdate.sh v1.14 (12th May 2014) by Andy Davison
#  Called by the JogglerUpdate applet to check for and install updates, and return changelog.
#  Also called by JogglerFeatures applet to check current version and installation medium.

PLATFORM=`cat /tmp/sqp_platform`

SERVER="http://birdslikewires.co.uk/download/joggler/squeezeplay"

if [ $# -eq 0 ] || [ $# -gt 2 ]; then
	echo "Usage: $0 <option>"
	echo
	echo "  clog <ver>:    Fetches the changelog, up to the currently installed version (ver)."
	echo "  id:            Returns this Joggler's ID (the wlan0 mac address)."
	echo "  oschk:         Returns the operating system version, if one is available."
	echo "  osint          Returns 1 if operating system is on internal memory, else returns 0."
	echo "  platform:      Returns the platform name."
	echo "  update:        Installs the latest update."
	echo "  verins:        Returns the version of SqueezePlay currently installed."
	echo "  verchk:        Checks with sever and returns the latest version number or 'NOUPDATE' if none."
	exit 0
fi

SPQVER=""
if [ "$PLATFORM" = "native" ]; then
	OSVER=`cat /etc/software.ver | awk '{print substr($1,1,5)}'`
	INSTALL_DIR="/media/opt"
	SUDO=""
else
	[ "$PLATFORM" = "sqpos" ] || OSVER=""
	[ "$PLATFORM" = "sqpos" ] && OSVER=`cat /etc/sqpos.ver`
	INSTALL_DIR="/opt"
	SUDO="sudo"
fi

if [ "$1" = "platform" ]; then
	echo -n $PLATFORM
	exit 0
fi

if [ "$1" = "oschk" ]; then
	echo -n $OSVER
	exit 0
fi

if [ "$1" = "osint" ]; then
	OSINTERNAL=`cat /etc/fstab | grep " / " | grep -c "mmcblk0"`
	[ $OSINTERNAL -eq 0 ] && echo "0"
	[ $OSINTERNAL -gt 0 ] && echo "1"
	exit 0
fi


jogglerid() {
	ID=""
	if [ "$PLATFORM" = "native" ]; then
		[ "$ID" = "" ] && ID=`ifconfig | grep ra0 | awk -F\HWaddr\  {'print $2'} | tr -d ' '  | tr "[:lower:]" "[:upper:]"`
	else
		[ "$ID" = "" ] && ID=`/bin/grep wlan0 /etc/udev/rules.d/70-persistent-net.rules 2>/dev/null | awk -F\address}==\" {'print $2'} | awk -F\" {'print $1'} | tr "[:lower:]" "[:upper:]"`
		[ "$ID" = "" ] && ID=`ifconfig | grep wlan | head -1 | awk -F\HWaddr\  {'print $2'} | tr -d ' ' | tr "[:lower:]" "[:upper:]"`
		[ "$ID" = "" ] && ID=`ifconfig | grep eth | head -1 | awk -F\HWaddr\  {'print $2'} | tr -d ' ' | tr "[:lower:]" "[:upper:]"`
	fi
	[ "$ID" = "" ] && ID="DE:AD:BE:EF:CA:FE"
}


## Basic requests first.

# Get the Joggler ID (wireless mac address).
jogglerid
[ "$1" = "id" ] && echo -n $ID

# Get the currently installed version of SqueezePlay for Joggler...
VERINS=`/bin/sed -n 1p $INSTALL_DIR/squeezeplay/version | tr  -d \'\n\'`
[ "$1" = "verins" ] && echo -n $VERINS

# ...and the currently installed SqueezePlay binaries themselves.
SQPINS=`/bin/sed -n 2p $INSTALL_DIR/squeezeplay/version | tr  -d \'\n\'`

# Check whether there are any newer versions.
if [ "$1" = "verchk" ]; then
	if [ -f /etc/sqpbeta ]; then
		VERCHK=`/usr/bin/wget -qO- "$SERVER/update.php?sys=$PLATFORM$OSVER&cli=applet&bin=$SQPINS&ver=$VERINS&id=$ID&beta=1"`
	else
		VERCHK=`/usr/bin/wget -qO- "$SERVER/update.php?sys=$PLATFORM$OSVER&cli=applet&bin=$SQPINS&ver=$VERINS&id=$ID"`
	fi
	echo -n $VERCHK
fi

# Output the changelog.
if [ "$1" = "clog" ]; then
	CLOG=`/usr/bin/wget -qO- "$SERVER/update.php?clog=$2"`
	echo "$CLOG"
fi


## Now for the update section, which is also pretty basic, really. Just have to get the installer script right.

if [ $1 = "update" ]; then
	
	$SUDO wget -qO $INSTALL_DIR/sqpinstall.sh $SERVER/sqpinstall.sh
	$SUDO chmod +x $INSTALL_DIR/sqpinstall.sh
	$SUDO $INSTALL_DIR/sqpinstall.sh applet > ~/.squeezeplay/update.log
	
fi

exit 0