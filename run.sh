#!/bin/bash
qemu-system-x86_64 -enable-kvm -m 512 -hda love-appimage.img -redir tcp:2222::22 -snapshot -curses
