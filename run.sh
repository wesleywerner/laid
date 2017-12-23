#!/bin/bash

# x86_64
qemu-system-x86_64 -enable-kvm -m 512 -hda laid-x86_64.img -redir tcp:2222::22 -snapshot -curses

# x86
# qemu-system-i386 -enable-kvm -m 512 -hda laid-x86.img -redir tcp:2222::22 -snapshot -curses
