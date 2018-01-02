#/bin/bash
#
# An automated build script that boots the VM (via QEmu), copies the
# game files to the build server, packages the AppImage and retrieves
# the result.
#
# This script assumes:
# * your game source lives under a "src" subdirectory
# * you have myapp.png and myapp.desktop files in the script directory.
# * you have set up your build servers and added them to ~/.ssh/config
#   as "laid32" and "laid64" respectively.
# * laid64 port forwards 2222:22
# * laid32 port forwards 3333:22
#
# Edit the enironment variables below as needed.
#
#  LICENSE
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see http://www.gnu.org/licenses/.

# ENVIRONMENT VARIABLES

# name of your AppImage to build
MYAPP="Fu App"

# game src directory (relative to this script)
SRCDIR=src

# path to our AppImage VM disks
VM_64_DISK=/media/data/virtualmachines/love-appimage/laid-x86_64.img
VM_32_DISK=/media/data/virtualmachines/love-appimage/laid-x86.img


# SCRIPT STARTS HERE

# QEmu commands
QEMU_64=qemu-system-x86_64
QEMU_32=qemu-system-i386

function powerdown {

    echo "Powering down..."
    ssh $LAID "systemctl poweroff"

}

function bootup {

    echo "Booting the build server..."
    sleep 6
    NEXT_WAIT_TIME=0
    RESULT=0
    until $(ssh -q $LAID exit) && RESULT=0 || [ $NEXT_WAIT_TIME -eq 10 ]; do
        echo "..."
        RESULT=$?
        (( NEXT_WAIT_TIME++ ))
        sleep 2
    done

    if [ ! $RESULT -eq 0 ];
    then
        echo "Failed to connect to build server."
        exit 255
    fi

    echo "Build server is up!"

}

function makezip {

    # zip the game files
    pushd $SRCDIR
    zip -r ../game.love .
    popd

}

function make {

    echo "Copying game files..."
    scp game.love myapp.desktop myapp.png $LAID:

    if [ ! $? -eq 0 ];
    then
        echo "Failed copying game.love myapp.desktop myapp.png"
        powerdown
        exit 255
    fi

    echo "Packaging AppImage..."
    ssh $LAID "source .bash_profile; ./package '$MYAPP'"

    echo "Copying result..."
    # fix race condition trying to scp after ssh
    sleep 1s
    scp $LAID:*.AppImage .

}

# You can optionally add the "-nographic" parameters to the qemu command
# to hide the extra window.

makezip

# x86_64 build
LAID=laid64
$QEMU_64 -enable-kvm -m 512 -hda $VM_64_DISK -redir tcp:2222::22 -snapshot &
bootup
make
powerdown

# x86 build
LAID=laid32
$QEMU_32 -enable-kvm -m 512 -hda $VM_32_DISK -redir tcp:3333::22 -snapshot &
bootup
make
powerdown
