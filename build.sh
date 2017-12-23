#/bin/bash
scp game.love myapp.desktop myapp.png laid64:
ssh laid64 'source .bash_profile; ./package "My App"'
# fix race condition trying to scp after ssh
sleep 2s
scp laid64:*.AppImage .
