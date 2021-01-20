#!/bin/sh

set -euxo pipefail

pacman -Sy
pacman -S vim

timedatectl set-ntp true

cfdisk /dev/nvme0n1
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2

mount /dev/nvme0n1p2 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

vim /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel linux linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt
