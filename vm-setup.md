# vm-setup

These steps will create a QEmu VM running a minimal debian jessie with SSH access.

You need to set up a seperate VM for 64-bit and 32-bit.

Create an empty directory where your VM's will live and cd into it.

* get the debian ISO:

        # 64-bit
        wget --no-clobber https://cdimage.debian.org/mirror/cdimage/archive/8.10.0/amd64/iso-cd/debian-8.10.0-amd64-netinst.iso

        # 32-bit
        wget --no-clobber https://cdimage.debian.org/mirror/cdimage/archive/8.10.0/i386/iso-cd/debian-8.10.0-i386-netinst.iso

* create a new disk:

        # 64-bit
        qemu-img create laid-x86_64.img 4G

        # 32-bit
        qemu-img create laid-x86.img 4G

* boot the debian ISO and carry out the installation:

        # 64-bit
        qemu-system-x86_64 -enable-kvm -cdrom debian-8.10.0-amd64-netinst.iso -boot d -m 512 -hda laid-x86_64.img

        # 32-bit
        qemu-system-i386 -enable-kvm -cdrom debian-8.10.0-i386-netinst.iso -boot d -m 512 -hda laid-x86.img

Observe these points during the install:

* ENTER a root password. This enables the root account which we will be using.
* At the "select software" screen uncheck EVERYTHING.

When the installation is complete, ensure the VM is powered off. Power it back on without the ISO, and add port forwarding for SSH access:

        # 64-bit
        qemu-system-x86_64 -enable-kvm -m 512 -hda laid-x86_64.img -redir tcp:2222::22

        # 32-bit
        qemu-system-i386 -enable-kvm -m 512 -hda laid-x86.img -redir tcp:2222::22

* In this case we forward the host port 2222 to the guest port 22.
* In QEmu this is the "-redir tcp:2222::22" parameter, also given under the network settings in QtEmu.
* In Virtual Box this is done under the machine network settings, use NAT and find "port forward" under Advanced.
* login as root and install SSH server and bash completion:

        ssh -p 2222 root@localhost

        # now inside the VM:
        apt-get install bash-completion openssh-server

* enable root login for ssh:

        # now inside the VM:
        vi /etc/ssh/sshd_config

        # change the option to read: `PermitRootLogin yes`

        # restart ssh in the VM to apply the setting
        /etc/init.d/ssh restart

I encourage you to add entries to `~/.ssh/config` (on your host) to alias the login process. Also adding public key authentication removes the password prompt (which is beyond the scope of this document).

    # ~/.ssh/config
    Host laid64
        HostName localhost
        Port 2222
        User root
        IdentityFile ~/.ssh/id_rsa_laid64

    Host laid32
        HostName localhost
        Port 3333
        User root
        IdentityFile ~/.ssh/id_rsa_laid32
