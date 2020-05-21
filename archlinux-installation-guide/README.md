This guide is based on [the offical installation guide](https://wiki.archlinux.org/index.php/installation_guide).

## Pre-installation for Mac users

This chapter is for users who want to install ArchLinux on Macbook. If you don't use Macbook, skip this chapter.

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

Reboot with USB drive. Press `alt` on rebooting and select the USB drive if you are using Macbook.

NOTE: If you're using the nVidia graphic card, the terminal prompt will be too tiny. In this case, you need to pass the kernel parameter `nomodeset` to disable the KMS. Please `e` when the boot menu shows up and add `nomodeset` at the end of the existing kernel parameters. See [this](https://wiki.archlinux.org/index.php/kernel_mode_setting#Disabling_modesetting) and [this](https://wiki.archlinux.org/index.php/Kernel_parameters#Syslinux).

### Verify the boot mode

If UEFI mode is enabled on an UEFI motherboard, Archiso will boot Arch Linux accordingly via systemd-boot. To verify this, list the efivars directory: 
```bash
ls /sys/firmware/efi/efivars
```
If the directory does not exist, the system may be booted in BIOS or CSM mode. Refer to your motherboard's manual for details.

### Connect to the Internet

**Only for laptops.**

```bash
sudo wifi-menu
sudo systemctl start dhcpcd
```

### Update the system clock

```bash
timedatectl set-ntp true  # Set to use NTP (Network Time Protocol)
timedatectl status
```

### Partition the disk

Check the device names and partition names
```bash
lsblk
```

Make partitions using cfdisk. Delete a empty partition created by Disk Utility on macOS, and create three new partition like belows.
```bash
cfdisk
```
If you have already installed Windows, you don't need to create the EFI system. It may be already created by Windows. See [this](https://wiki.archlinux.org/index.php/Dual_boot_with_Windows#Installation).
```
/dev/sda3 - EFI System / 512M
/dev/sda4 - Linux swap / 4G (Same size with the physical memory)
/dev/sda5 - Linux filesystem / Remaining size
```

Select `Write` and `Quit`.

### Format partitions

Format two partitions, `/dev/sda3` and `/dev/sda5`. Don't format `/dev/sda4` for now.

```bash
mkfs.fat -F32 /dev/sda3  # Only if you created the EFI system (not by Windows)
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

Move the fastest mirror to the top of the list.

### Install base packages

```bash
pacstrap /mnt base base-devel linux linux-firmware
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
```

### Network configuration

Create the hostname file.
```bash
echo "oudwud-arch" > /etc/hostname
```

Add matching entries to:
```bash
vi /etc/hosts
```
```
127.0.0.1    localhost
::1          localhost
127.0.1.1    oudwud-arch.localdomain oudwud-arch
```

### Root passwd

```bash
passwd
```

### Install WIFI package and Enable Network services

```bash
sudo pacman -S iwd
sudo systemctl enable --now iwd
sudo systemctl enable --now dhcpcd
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

Use the PARTUUID of the `/` partition.
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

### Enable the Internet temporary.

**For WiFi:**

```
sudo iwctl

[iwd] device list
[iwd] station wlan0 scan
[iwd] station wlan0 get-networks
[iwd] station wlan0 connect SSID
[iwd] exit
```

### Update the pacman

```bash
sudo pacman -Syu
```

### Install the nVidia driver

If you're using the nVidia graphic card, the terminal prompt is too tiny to read. You need to install the nVidia driver.
```bash
sudo pacman -S nvidia
sudo reboot
```

### Install NTP (Network Time Protocol)

```bash
sudo pacman -S ntp
sudo systemctl enable --now ntpd.service
timedatectl status
```

To dual boot with Windows, [configure Windows to use UTC](https://wiki.archlinux.org/index.php/System_time#UTC_in_Windows) by the hardware clock.

### Set Microcode

```bash
sudo pacman -S intel-ucode
```

Add a line on `/boot/loader/entries/entry.conf`, above the line of `initrd /initramfs-linux.img`.
```
...
initrd /intel-ucode.img
initrd /initramfs-linux.img
...
```

```bash
sudo bootctl update
sudo reboot
```

### Install xorg

```bash
sudo pacman -S xorg-server xorg-apps
sudo pacman -S xorg-twm xorg-xclock xorg-setxkbmap xterm
```

### Install Macbook graphic driver

Only for Macbook users.
First, identify the graphic card.
```bash
lspci | grep -e VGA -e 3D
```

Maybe, the graphic card of MacBook Air is made by Intel.
```bash
sudo pacman -S xf86-video-intel
```

### Install Xfce and i3-wm

Install Xfce
```bash
sudo pacman -S xfce4 xfce4-goodies
sudo pacman -S xorg-xinit
cp /etc/X11/xinit/xinitrc ~/.xinitrc
```

Install i3-wm
```bash
sudo pacman -S i3-wm dmenu i3status
```

Add the following to the bottom of `~/.bash_profile`. The `startx` will start the xorg-server with `~/.xinitrc`.
```
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
fi
```

Add the following to the bottom of `~/.xinitrc`.
```bash
exec i3
```

If you want to use other desktop environments, see [this](https://wiki.archlinux.org/index.php/Dual_boot_with_Windows#Installation).

### Install everything

```bash
# CapsLock to Ctrl
# add the following to the ~/.xinitrc
setxkbmap -option ctrl:nocaps

# font
sudo pacman -S ttf-dejavu

# firefox
sudo pacman -S firefox flashplugin

# audio utils
sudo pacman -S alsa-utils
alsamixer
speaker-test -c 2

# mic
sudo pacman -S pulseaudio
sudo pacman -S pavucontrol
sudo reboot
pavucontrol

# display brightness
sudo pacman -S light
sudo usermod -a -G video $USER
# add the following lines in `~/.config/i3/config`.
bindsym XF86MonBrightnessUp exec light -A 10
bindsym XF86MonBrightnessDown exec light -U 10

# bluetooth
sudo pacman -S bluez bluez-utils
# check if bluetooth is blocked
sudo rfkill list
# if blocked, unblock it
sudo rfkill unblock bluetooth
# enable it
sudo systemctl enable --now bluetooth
sudo pacman -S blueman
blueman-manager

# yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# NanumGothic font
yay -S ttf-nanum

# nimf Korean input method (managed by hamonikr)
yay -S nimf-git
nimf-settings
# edit ~/.xinitrc : https://wiki.archlinux.org/index.php/Nimf

# auto power regulation
sudo pacman -S tlp
sudo systemctl enable --now tlp

# xscreensaver
sudo pacman -S xscreensaver xss-lock
vi ~/.xinitrc
# add the following commands
# xscreensaver -no-splash &
# xss-lock -- xscreensaver-command -lock &
```

--------------------------------------------------
# Old info

### Turn the Internet on when startup

Only for laptops.
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

### Install yay

```bash

```

### Install the Korean font

```bash
```

### Install the Korean input method

```bash
sudo pacman -S ibus ibus-hangul
ibus-setup
```

Enable `Start in hangul mode`.

Add the line `ibus-daemon -xdr` before the line `exec i3` in the `~/.xinitrc`.
Instead, you can use my [.xinirc](https://github.com/oudwud/me/blob/master/.xinitrc).


## Laptop Hardware Setup
 
### Trackpad

Don't use synaptics or mtrack. They are utter crap.

Xorg-server will come with libinput driver installed, and the libinput is enough. Wayland is using libinput for a reason as well.

Create `/etc/X11/xorg.conf.d/30-touchpad.conf`.
```
Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
    Option "ClickMethod" "clickfinger"
    Option "AccelProfile" "flat"
EndSection
```

```bash
sudo reboot
```

### Facetime WebCam driver

```bash
yay -S bcwc-pcie-git
```

### Bluetooth

```bash

```

### MBP Fan Usage

```bash
yay -S mbpfan-git
sudo systemctl enable --now mbpfan
```

### Automated Power Regulation

```bash
sudo pacman -S tlp
sudo systemctl enable --now tlp
```

### Overheat shutoff

```bash
yay -S thermald
sudo systemctl enable --now thermald
```

### Display brightness

```bash
yay -S light-git
```

Add the following lines in `~/.config/i3/config`.

```
bindsym XF86MonBrightnessUp exec light -A 10
bindsym XF86MonBrightnessDown exec light -U 10
```

### Keyboard backlight

```bash
kbdlight max
```
