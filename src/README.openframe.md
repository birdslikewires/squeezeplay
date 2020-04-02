Building on Linux for OpenFrame
================================

This was tested using a 32-bit chroot on Ubuntu Bionic 18.04.4 LTS, using gcc 7.5.0.

`make -f Makefile.openframe`

## Requirements:

You will need to remove the following packages:

* libjpeg-dev
* libjpeg-turbo8-dev

Or in other words:

`apt remove libjpeg-turbo8-dev ; apt autoremove`

You will need to install the following packages:

* build-essential
* git
* flex
* bison
* automake
* libtool
* libpng-dev
* libjpeg9-dev
* libexpat1-dev
* libreadline-dev
* libncurses5-dev
* libasound2-dev
* scons
* xorg-dev
* zlib1g-dev

Or in other words:

`apt install build-essential git flex bison automake libtool libpng-dev libjpeg9-dev libexpat1-dev libreadline-dev libncurses5-dev libasound2-dev scons xorg-dev zlib1g-dev`

Good luck.