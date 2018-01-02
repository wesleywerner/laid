#!/bin/bash
#
# LOVE APPIMAGE SETUP SCRIPT
#
# SCRIPT VERSION 1
# LOVE VERSION 0.10.2
# ARCH 32

export LAIDVERSION=1
echo -e "LAID x86 version $LAIDVERSION log $(date)" 2>&1 | tee log.txt

export LOVE_SOURCE_URL=https://bitbucket.org/rude/love/get/0.10.2.tar.gz
export CARE_URL=https://github.com/proot-me/proot-static-build/raw/master/static/care-x86
export APPIMAGE_TOOL_URL=https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-i686.AppImage
export APPRUN_URL=https://github.com/AppImage/AppImageKit/releases/download/continuous/AppRun-i686

# Set up the build path environment variable. For now this is in the user's home
if [ -z $BUILDPATH ]
then
  cd
  export BUILDPATH=$(pwd)
  echo "export BUILDPATH=$BUILDPATH" > ~/.bash_profile
else
  echo "* build path OK" 2>&1 | tee -a $BUILDPATH/log.txt
fi

# install fuse, this is required by AppImages
dpkg-query -l fuse &> /dev/null
if [ $? -eq 1 ];
then
  apt-get --assume-yes install fuse 2>&1 | tee -a $BUILDPATH/log.txt && modprobe fuse
else
  echo "* fuse installed OK" 2>&1 | tee -a $BUILDPATH/log.txt
fi

# install build dependencies for love
dpkg-query -l build-essential &> /dev/null
if [ $? -eq 1 ];
then
  apt-get --assume-yes install build-essential autotools-dev automake libtool pkg-config libdevil-dev libfreetype6-dev libluajit-5.1-dev libphysfs-dev libsdl2-dev libopenal-dev libogg-dev libvorbis-dev libflac-dev libflac++-dev libmodplug-dev libmpg123-dev libmng-dev libturbojpeg1 libtheora-dev ca-certificates 2>&1 | tee -a $BUILDPATH/log.txt
else
  echo "* love dependencies OK" 2>&1 | tee -a $BUILDPATH/log.txt
fi

# get love source
if [ ! -e $BUILDPATH/love-source/*.gz ];
then
  mkdir -p $BUILDPATH/love-source
  cd $BUILDPATH/love-source
  wget --no-clobber $LOVE_SOURCE_URL 2>&1 | tee -a $BUILDPATH/log.txt
  tar -xvzf *.gz
else
  echo "* love source OK" 2>&1 | tee -a $BUILDPATH/log.txt
fi

# build love
if [ -z $(which love) ];
then
  cd $BUILDPATH/love-source/rude-love*
  ./platform/unix/automagic 2>&1 | tee -a $BUILDPATH/log.txt
  ./configure 2>&1 | tee -a $BUILDPATH/log.txt
  make 2>&1 | tee -a $BUILDPATH/log.txt
  make install 2>&1 | tee -a $BUILDPATH/log.txt
else
  echo "* love installed OK" 2>&1 | tee -a $BUILDPATH/log.txt
fi

# get care
if [ ! -e $BUILDPATH/tools/care ];
then
  mkdir -p $BUILDPATH/tools
  cd $BUILDPATH/tools
  wget --no-clobber -O care $CARE_URL 2>&1 | tee -a $BUILDPATH/log.txt
  chmod +x care
else
  echo "* proot care OK" 2>&1 | tee -a $BUILDPATH/log.txt
fi

# get AppImage
if [ ! -e $BUILDPATH/tools/appimagetool.AppImage ];
then
  mkdir -p $BUILDPATH/tools
  cd $BUILDPATH/tools
  wget --no-clobber -O appimagetool.AppImage $APPIMAGE_TOOL_URL 2>&1 | tee -a $BUILDPATH/log.txt
  wget --no-clobber -O AppRun $APPRUN_URL 2>&1 | tee -a $BUILDPATH/log.txt
  chmod +x appimagetool.AppImage
else
  echo "* AppImage OK" 2>&1 | tee -a $BUILDPATH/log.txt
fi

# collate love and it's dependencies
if [ ! -e $BUILDPATH/love-portable/portable.tar.gz ];
then
  mkdir -p $BUILDPATH/love-portable
  cd $BUILDPATH/love-portable
  $BUILDPATH/tools/./care -o portable.tar.gz love 2>&1 | tee -a $BUILDPATH/log.txt
  $BUILDPATH/tools/./care -x portable.tar.gz 2>&1 | tee -a $BUILDPATH/log.txt
  echo "converting binaries to use relative paths..."
  cd $BUILDPATH/love-portable/portable/rootfs/usr/
  find . -type f -exec sed -i -e 's#/usr#././#g' {} \;
  echo "done"
else
  echo "* love collated OK" 2>&1 | tee -a $BUILDPATH/log.txt
fi

echo -e "\nAll done.\nRun this script again to validate setup status.\nIf all OK then power off."
