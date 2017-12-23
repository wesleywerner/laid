# LAID

LAID is a collection of bash scripts to set up a build server for packaging AppImages to run LÖVE games.

The build server runs Debian Jessie, it has SSH access and runs in snapshot mode so that each boot gives a clean environment.

LAID is an acronym for Löve AppImage builDer.

## setting up

Set up happens once.

1. [vm-setup.md](vm-setup.md) details creating a new VM in QEmu. You can adapt this guide to virtual box too.
1. boot your VM

        qemu-system-x86_64 -enable-kvm -m 512 -hda love-appimage.img -redir tcp:2222::22

1. copy package script:

        scp laid-0.10.2-x86_64-package.sh appimage:package
        ssh appimage "chmod +x package"

1. run the setup script:

        scp laid-0.10.2-x86_64-setup.sh appimage:setup
        ssh appimage    # remote into VM
        chmod +x setup
        ./setup

## packaging your game

Boot the VM with the `-snapshot -curses` options, the snapshot mode discards any changes on the VM, keeping your environment clean. The file [run.sh](run.sh) implements this, edit and use it as you need.

    qemu-system-x86_64 -enable-kvm -m 512 -hda love-appimage.img -redir tcp:2222::22 -snapshot -curses

Copy these files to the VM:

* game.love
* myapp.png (a 256x256 image)

Assuming you have a ssh host config named "appimage" as detailed in vm-setup:

    scp game.love myapp.desktop myapp.png appimage:
    ssh appimage
    ./package "My App"

You can now copy the AppImage out

    scp appimage:*.AppImage .

If you want to package without interactive login, source bash_profile so the build environment is loaded correctly:

    ssh appimage 'source .bash_profile; ./package "My App"'

The file [build.sh](build.sh) implements this, copy and change as you need.

# license

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see http://www.gnu.org/licenses/.

