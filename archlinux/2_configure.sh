#!/bin/bash

set -euxo pipefail

MY_HOST="t490-arch"
MY_USER="oudwud"
USER_HOME="/home/${MY_USER}"
ROOT_PARTITION="/dev/nvme0n1p2"

pacman -Syu
pacman -S vim

ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
hwclock --systohc

vim /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "${MY_HOST}" > /etc/hostname
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    ${MY_HOST}.localdomain ${MY_HOST}" >> /etc/hosts

mkinitcpio -P

passwd

useradd -m -g users -G wheel -s /bin/bash ${MY_USER}
passwd ${MY_USER}

EDITOR=vim visudo
# Uncomment #%wheel ALL=...

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
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value ${ROOT_PARTITION}) rw">> /boot/loader/entries/arch.conf 

pacman -S networkmanager network-manager-applet
systemctl enable NetworkManager.service

pacman -S pulseaudio pulseaudio-bluetooth pavucontrol pasystray bluez bluez-utils blueman
systemctl enable bluetooth.service
vim /etc/bluetooth/main.conf
# Set AutoEnable=true in the [Policy] section
# [Policy]
# AutoEnable=true

pacman -S xorg-server xorg-xinit
pacman -S xfce4 xfce4-goodies

cp /etc/X11/xinit/xinitrc ${USER_HOME}/.xinitrc
echo "exec startxfce4" >> ${USER_HOME}/.xinitrc

echo "if [ -z \"\${DISPLAY}\" ] && [ \"\${XDG_VTNR}\" -eq 1 ]; then" >> ${USER_HOME}/.bashrc
echo "\texec startx" >> ${USER_HOME}/.bashrc
echo "fi" >> ${USER_HOME}/.bashrc

pacman -S firefox git jq xclip openssh xorg-xrandr arandr autorandr
pacman -S ttf-baekmuk ttf-liberation ttf-dejavu noto-fonts

pacman -S ibus ibus-hangul
echo "GTK_IM_MODULE=ibus" >> /etc/environment
echo "QT_IM_MODULE=ibus" >> /etc/environment
echo "XMODIFIERS=@im=ibus" >> /etc/environment
mkdir -p ${USER_HOME}/.config/autostart
touch ${USER_HOME}/.config/autostart/ibus-daemon.desktop
echo "[Desktop Entry]" >> ${USER_HOME}/.config/autostart/ibus-daemon.desktop
echo "Name=IBus Daemon" >> ${USER_HOME}/.config/autostart/ibus-daemon.desktop
echo "Exec=ibus-daemon -drx" >> ${USER_HOME}/.config/autostart/ibus-daemon.desktop
