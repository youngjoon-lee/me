#!/bin/bash

set -euxo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#${DIR}/../dotfiles/install.sh

sudo pacman -S go nodejs yarn jdk-openjdk
sudo pacman -S code alacritty

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

mkdir -p ~/repos
git clone https://aur.archlinux.org/yay.git ~/repos/yay
cd ~/repos/yay
makepkg -si
cd -

yay -S intellij-idea-ultimate-edition
yay -S ttf-nanum
