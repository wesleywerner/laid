#!/bin/bash
#
# LOVE APPIMAGE PACKAGE SCRIPT
#
# SCRIPT VERSION 1
# LOVE VERSION 0.10.2
# ARCH 64
#
# This script gets installed by the setup script as "package".
# To package your game you must copy these files to the VM:
#
# * game.love
# * myapp.png (a 256x256 image)
#
# Assuming you have a host config named "appimage" pointing to the VM
# build your AppImage with:
#
# scp game.love myapp.png appimage:
# ssh appimage
# ./package "You Game Name"
#
#

if [ -z $BUILDPATH ];
then
  echo "BUILDPATH is not set, run the setup script to configure this VM.";
  exit 1;
fi

if [ $# -eq 0 ];
then
  echo "specify the game name as parameter";
  exit 1;
fi

if [ ! -e $BUILDPATH/game.love ];
then
  echo "game.love not found in the build path"
  exit 1;
fi

if [ ! -e $BUILDPATH/myapp.png ];
then
  echo "warning: myapp.png not found"
  exit 1;
fi

export BUILDIR=$BUILDPATH/builds/MyApp.AppDir
echo "creating $BUILDIR..."
mkdir -p $BUILDIR
cp -r $BUILDPATH/love-portable/portable/rootfs/* $BUILDIR/
cd $BUILDIR
cp $BUILDPATH/tools/AppRun-x86_64 ./AppRun
chmod +x AppRun

echo "copying game.love"
cp $BUILDPATH/game.love $BUILDIR/usr/bin/
cp $BUILDPATH/myapp.png $BUILDIR/

# create desktop file
cat >$BUILDIR/myapp.desktop <<EOL
[Desktop Entry]
Name=$1
Exec=myapp
Icon=myapp
Type=Application
Categories=Game;
EOL

echo "fusing your game with the love binary..."
cd $BUILDIR/usr/bin
cat love $BUILDPATH/game.love > myapp
chmod +x myapp

echo "building AppImage..."
cd $BUILDPATH
$BUILDPATH/tools/./appimagetool-x86_64.AppImage $BUILDIR

echo -e "\nPackaging complete:"
ls -lh *.AppImage
