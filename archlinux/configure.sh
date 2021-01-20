#!/bin/bash

set -euxo pipefail

pacman -Syu
pacman -S vim

ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
hwclock --systohc

vi /etc/locale-gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

MY_HOST="t490-arch"
echo "${MY_HOST}" > /etc/hostname
echo "127.0.0.1\tlocalhost" >> /etc/hosts
echo "::1\tlocalhost" >> /etc/hosts
echo "127.0.1.1\t${MY_HOST}.localdomain ${MY_HOST}" >> /etc/hosts

mkinitcpio -P

passwd

MY_USER="oudwud"
useradd -m -g users -G wheel -s /bin/bash ${MY_USER}
passwd ${MY_USER}

EDITOR=vim visudo
# Uncomment #%wheel ALL=

pacman -S intel-ucode

bootctl --path=/boot install

rm -f /boot/loader/loader.conf
touch /boot/loader/loader.conf
echo "default arch.conf" >> /boot/loader/loader.conf
echo "timeout 3" >> /boot/loader/loader.conf
echo "editor 1" >> /boot/loader/loader.conf

rm -f /boot/loader/entries/arch.conf
touch /boot/loader/entries/arch.conf
echo "title ArchLinux" >> /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/nvme0n1p2) rw">> /boot/loader/entries/arch.conf 



pacman -S networkmanager network-manager-applet
systemctl enable --now NetworkManager.service

pacman -S pulseaudio pulseaudio-bluetooth pavucontrol pasystray bluez bluez-utils blueman blueman-applet blueman-manager
systemctl enable --now bluetooth.service
vim /etc/bluetooth/main.conf
# Set AutoEnable=true in the [Policy] section
# [Policy]
# AutoEnable=true

pacman -S xorg-server xorg-xinit
pacman -S xfce4 xfce4-goodies

cp /etc/X11/xinit/xinitrc ~/.xinitrc
echo "exec startxfce4" >> ~/.xinitrc

echo "if [ -z \"\${DISPLAY}\" ] && [ \"\${XDG_VTNR}\" -eq 1 ]; then" >> /home/oudwud/.bashrc
echo "\texec startx" >> /home/oudwud/.bashrc
echo "fi" >> /home/oudwud/.bashrc

pacman -S firefox git jq ttf-baekmuk xclip
