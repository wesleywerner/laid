# vm-setup

These steps will create a QEmu VM running a minimal debian jessie with SSH access.

Begin by creating an empty directory where your VM will live and cd into it.

* get the debian ISO:

    wget --no-clobber https://cdimage.debian.org/mirror/cdimage/archive/8.10.0/amd64/iso-cd/debian-8.10.0-amd64-netinst.iso

* create a new disk:

    qemu-img create love-appimage.img 4G

* boot the debian ISO and carry out the installation:

    qemu-system-x86_64 -enable-kvm -cdrom debian-8.10.0-amd64-netinst.iso -boot d -m 512 -hda love-appimage.img

Observe these points during the install:

* ENTER a root password. This enables the root account which we will be using.
* At the "select software" screen uncheck EVERYTHING.

When the installation is complete, ensure the VM is powered off. Power it back on without the ISO, and add port forwarding for SSH access:

    qemu-system-x86_64 -enable-kvm -m 512 -hda love-appimage.img -redir tcp:2222::22

* In this case we forward the host port 2222 to the guest port 22.
* In QEmu this is the "-redir tcp:2222::22" parameter, also given under the network settings in QtEmu.
* In Virtual Box this is done under the machine network settings, use NAT and find "port forward" under Advanced.
* login as root and install SSH server and bash completion:

    apt-get install bash-completion openssh-server

* enable root login for ssh:

    vi /etc/ssh/sshd_config # change the option to read: PermitRootLogin yes
    /etc/init.d/ssh restart

Open a new terminal on the host, we can now login remotely and enjoy
the benefits of pasting the rest of the commands!

    ssh -p 2222 root@localhost

I encourage you to add a entry (on your host) to `~/.ssh/config` to smooth the process. Also adding public key authentication removes the password prompt (beyond the scope of this document).

    Host appimage
        HostName localhost
        Port 2222
        User root
        IdentityFile ~/.ssh/id_rsa_appimage
