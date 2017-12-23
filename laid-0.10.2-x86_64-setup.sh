#!/bin/bash
#
# LOVE APPIMAGE SETUP SCRIPT
#
# SCRIPT VERSION 1
# LOVE VERSION 0.10.2
# ARCH 64
#
# This script should be run on a fresh, minimal debian jessie installation.
# Refer to the love-appimage-qemu-setup.txt file for getting your VM up and running.
#
# 1) boot your VM
# qemu-system-x86_64 -enable-kvm -m 512 -hda love-appimage.img -redir tcp:2222::22
#
# 2) SSH into the VM and download this script
# ssh appimage
# wget SCRIPT-URL
# chmod +x love-0.10.2-appimage-x86_64-setup.sh
#
# 3) execute
# ./love-0.10.2-appimage-x86_64-setup.sh
#
# When setup is complete, power it off (systemctrl poweroff)
# From here on boot the VM with the "-snapshot" parameter.
# It makes the base image read-only and changes are discarded on poweroff.
# This gives you a clean build environment each time you boot.
#
# The "-curses" option disables the graphical window (there is no gui anyway)
# and you can switch to command mode with ESC-2 (and back with ESC-1)
# to issue the ACPI "system_powerdown" command.
#
# qemu-system-x86_64 -enable-kvm -m 512 -hda love-appimage.img -redir tcp:2222::22 -snapshot -curses

# Set up the build path environment variable. For now this is in the user's home
if [ -z $BUILDPATH ]
then
  cd
  export BUILDPATH=$(pwd)
  echo "export BUILDPATH=$BUILDPATH" > ~/.bash_profile
else
  echo "* build path OK"
fi

# install fuse, this is required by AppImages
dpkg-query -l fuse &> /dev/null
if [ $? -eq 1 ];
then
  apt-get --assume-yes install fuse && modprobe fuse
else
  echo "* fuse installed OK"
fi

# install build dependencies for love
dpkg-query -l build-essential &> /dev/null
if [ $? -eq 1 ];
then
  apt-get --assume-yes install build-essential autotools-dev automake libtool pkg-config libdevil-dev libfreetype6-dev libluajit-5.1-dev libphysfs-dev libsdl2-dev libopenal-dev libogg-dev libvorbis-dev libflac-dev libflac++-dev libmodplug-dev libmpg123-dev libmng-dev libturbojpeg1 libtheora-dev ca-certificates
else
  echo "* love dependencies OK"
fi

# get love source
if [ ! -e $BUILDPATH/love-source/0.10.2.tar.gz ];
then
  mkdir -p $BUILDPATH/love-source
  cd $BUILDPATH/love-source
  wget --no-clobber https://bitbucket.org/rude/love/get/0.10.2.tar.gz
  tar -xvzf 0.10.2.tar.gz
else
  echo "* love source OK"
fi

# build love
if [ -z $(which love) ];
then
  cd $BUILDPATH/love-source/rude-love*
  ./platform/unix/automagic
  ./configure
  make
  make install
else
  echo "* love installed OK"
fi

# get care
if [ ! -e $BUILDPATH/tools/care-x86_64 ];
then
  mkdir -p $BUILDPATH/tools
  cd $BUILDPATH/tools
  wget --no-clobber https://github.com/proot-me/proot-static-build/raw/master/static/care-x86_64
  chmod +x care-x86_64
else
  echo "* proot care OK"
fi

# get AppImage
if [ ! -e $BUILDPATH/tools/appimagetool-x86_64.AppImage ];
then
  mkdir -p $BUILDPATH/tools
  cd $BUILDPATH/tools
  wget --no-clobber https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
  wget --no-clobber https://github.com/AppImage/AppImageKit/releases/download/continuous/AppRun-x86_64
  chmod +x appimagetool-x86_64.AppImage
else
  echo "* AppImage OK"
fi

# collate love and it's dependencies
if [ ! -e $BUILDPATH/love-portable/portable.tar.gz ];
then
  mkdir -p $BUILDPATH/love-portable
  cd $BUILDPATH/love-portable
  $BUILDPATH/tools/./care-x86_64 -o portable.tar.gz love
  $BUILDPATH/tools/./care-x86_64 -x portable.tar.gz
  echo "converting binaries to use relative paths..."
  cd $BUILDPATH/love-portable/portable/rootfs/usr/
  find . -type f -exec sed -i -e 's#/usr#././#g' {} \;
  echo "done"
else
  echo "* love collated OK"
fi

echo -e "\nAll done.\nRun this script again to validate setup status.\nIf all OK then power off."
