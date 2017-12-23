# LAID

LAID is a collection of bash scripts to set up a build server for packaging AppImages to run LÖVE games.

The build server runs Debian Jessie, it has SSH access and runs in snapshot mode so that each boot gives a clean environment.

LAID is an acronym for Löve AppImage builDer.

## setting up

Set up happens once.

1. Follow [vm-setup.md](vm-setup.md) to create a new VM in QEmu. You can adapt this guide to virtual box too.
1. boot your VM using [run.sh](run.sh) as a template.
1. copy the package script:

        scp laid-0.10.2-package.sh laid64:package
        ssh laid64 "chmod +x package"

1. run the setup script:

        scp laid-0.10.2-x86_64-setup.sh laid64:setup
        ssh laid64 "chmod +x setup"
        ssh laid64 # remote into VM
        ./setup

The setup downloads build dependencies, love source and AppImage tools. This takes about ten minutes. When complete, run setup again, it will validate everything is installed. If there are problems refer to the `log.txt` file.

## packaging your game

Boot the VM with the `-snapshot -curses` options, the snapshot mode discards any changes on the VM, keeping your environment clean. The file [run.sh](run.sh) implements this, edit and use it as you need.

    qemu-system-x86_64 -enable-kvm -m 512 -hda laid-x86_64.img -redir tcp:2222::22 -snapshot -curses

Copy these files to the VM:

* game.love
* myapp.png (a 256x256 image)

Assuming you have a ssh host config named "laid64" as detailed in vm-setup:

    scp game.love myapp.desktop myapp.png laid64:
    ssh laid64
    ./package "My App"

You can now copy the AppImage out

    scp laid64:*.AppImage .

If you want to package without interactive login, source bash_profile so the build environment is loaded correctly:

    ssh laid64 'source .bash_profile; ./package "My App"'

The file [build.sh](build.sh) implements this, copy and change as you need.

**note** The process calls `care` which tries to execute love, resulting in a "XDG_RUNTIME_DIR not set" error, since we are not running any xserver. This is fine and care still succeeds in capturing love as a portable binary.

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

