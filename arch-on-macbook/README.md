## Pre-installation

### Download ArchLinux image

From ArchLinux website

### Shrink Mac Partition

Using the Disk Utility on macOS.
Don't create three partitions for `/boot`, `/` and `swap`.
Just create one empty partition. The filesystem isn't significant for now. 

### Make USB installation media

Reference: [here](https://wiki.archlinux.org/index.php/USB_flash_installation_media#In_macOS)

In macOS, check the device name.
```bash
diskutil list
```

Unmount the USB drive before block-writing to with `dd`.
```bash
diskutpil unmountDisk /dev/diskK
```

Now copy the ISO file to the USB device.
```bash
dd if=path/to/arch.iso of=/dev/rdiskX bs=1m
```

Don't forget to append `r` before `diskX`.

## Installation

Reference: [here](https://wiki.archlinux.org/index.php/Installation_guide#Pre-installation) and [here](https://withjeon.com/2017/11/07/arch-linux-install-guide/)

Reboot with USB drive. Press `alt` on rebooting and select the USB drive.

### Verify the boot mode

If UEFI mode is enabled on an UEFI motherboard, Archiso will boot Arch Linux accordingly via systemd-boot. To verify this, list the efivars directory: 
```bash
ls /sys/firmware/efi/efivars
```
If the directory does not exist, the system may be booted in BIOS or CSM mode. Refer to your motherboard's manual for details.

### Connect to the Internet

```bash
sudo wifi-menu
sudo systemctl start dhcpcd
```

### Update the system clock

```bash
timedatectl set-ntp true
timedatectl status
```

### Partition the disk

Check the device names and partition names
```bash
lsblk
```

Make partitions using cfdisk
```bash
cfdisk
```

Delete a empty partition created by Disk Utility on macOS, and create three new partition like belows.
```
/dev/sda3 - EFI System / 512M
/dev/sda4 - Linux swap / 4G
/dev/sda5 - Linux filesystem / Remaining size
```

Select `Write` and `Quit`.

### Format partitions

Format two partitions, `/dev/sda3` and `/dev/sda5`. Don't format `/dev/sda4` for now.

```bash
mkfs.fat -F32 /dev/sda3
mkfs.ext4 /dev/sda5
```

### Make swap 

```bash
mkswap /dev/sda4
swapon /dev/sda4
```

### Mount partitions

```bash
mount /dev/sda5 /mnt
mkdir /mnt/boot
mount /dev/sda3 /mnt/boot
```

### Select the mirror list

I skipped this step.

### Install base packages

```bash
pacstrap /mnt base base-devel
```



## Configuration

### Fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
```

### Chrot

```bash
arch-chroot /mnt
```

### Time zone

```bash
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
```

### Localization

Uncomment the locale you want to install.
```bash
vi /etc/locale.gen
```

Generate them with:
```bash
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
```

### Network configuration

Create the hostname file.
```bash
echo "oudwud-macbook-air" > /etc/hostname
```

Add matching entries to:
```bash
vi /etc/hosts
```
```
127.0.0.1	localhost
::1			localhost
127.0.1.1	oudwud-macbook-air.localdomain oudwud-macbook-air
```

### Root passwd

```bash
passwd
```

### Install WIFI packages

```bash
pacman -S dialog
```

Check the `wifi-menu` works well.
```bash
wifi-menu
```

Enable the `dhcpcd` service to start after boot.
```bash
sudo systemctl enable dhcpcd
```

### Add an user

```bash
useradd -m -G users,wheel -s /bin/bash oudwud
passwd oudwud
```

Edit `sudoers` using `visudo`
```bash
EDITOR=vi visudo
```
Uncomment `%wheel ALL= ...`.

### Install the boot loader

```bash
bootctl --path=/boot install

vi /boot/loader/loader.conf
```
```
default arch
editor 1
timeout 3
```

```bash
vi /boot/loader/entries/arch.conf
```
```
title ArchLinux
linux /vmlinuz-linux
initrd /initramfs-linux.img
```
```bash
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sda5) rw" >> /boot/loader/entries/arch.conf
```

### Reboot

```bash
exit
umount -R /mnt
reboot
```

## Post-installation

### Install the desktop environment

Enable the Internet temporary

```
sudo wifi-menu
sudo systemctl start dhcpcd
```

### Update the pacman

```bash
sudo pacman -Syu
```

### Set Microcode

```bash
sudo pacman -S intel-ucode
```

Add a line on `/boot/loader/entries/entry.conf`, above the line of `initrd /initramfs-linux.img`.
``
...
initrd /intel-ucode.img
initrd /initramfs-linux.img
...
```

```bash
sudo bootctl update
reboot
```

### Install xorg

```bash
sudo pacman -S xorg-server xorg-server-utils xorg-init
sudo pacman -S xorg-twm xorg-xclock xterm
```

And install the graphic drivers. First, identify the graphic card.
```bash
lspci | grep -e VGA -e 3D
```

Maybe, the graphic card of MacBook Air is made by Intel.
```bash
sudo pacman -S xf86-video-intel
```

### Install Xfce

```bash
sudo pacman -S xfce4 xfce4-goodies
sudo pacman -S xorg-xinit
cp /etc/X11/xinit/xinitrc ~/.xinitrc
```

Add the following to the bottom of `~/.bash_profile`.
```
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
fi
```

Add the following to the bottom of `~/.xinitrc`.
```bash
session=${1:-xfce} # Here Xfce is kept as default

case $session in
    i3|i3wm           ) exec i3;;
    kde               ) exec startkde;;
    xfce|xfce4        ) exec startxfce4;;
    # No known session, try to run it as command
    *                 ) exec $1;;
esac
```

### Install the i3-wm

```bash
sudo pacman -S i3-wm dmenu i3status
```

### Install the font

```bash
sudo pacman -S ttf-dejavu
```

### Install the Firefox

```bash
sudo pacman -S firefox flashplugin
```

### Turn the Internet on when startup

Check the name of the network interface.
```bash
ip addr
```

Enable the service. (Assume the name of interface is `wlp2s0b1`.)
```bash
sudo pacman -S wpa_actiond
sudo systemctl enable netctl-auto@wlp2s0b1
sudo reboot
```

### Install the Korean font

Download the `ttf-nanum` snapshot from `aur.archlinux.org`.
```bash
tar xvzf ttf-nanum.tar.gz
cd ttf-nanum.tar.gz
makepkg -sic
```

### Install the Korean input method

```bash
sudo pacman -S ibus ibus-hangul
ibus-setup
sudo reboot
```

Click the ibus icon bottom-right of the screen and enable `Start in hangul mode`.

