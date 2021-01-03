#!/bin/bash

set -euxo pipefail

# update repos
sudo pacman -Sy

# firefox
sudo pacman -S firefox

# utils / drivers
sudo pacman -S autorandr pulseaudio-bluetooth

# fonts
sudo pacman -S ttf-baekmuk
