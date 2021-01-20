#!/bin/bash

set -euxo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ln -s ${DIR}/.Xmodmap ~/.Xmodmap
ln -s ${DIR}/.tmux.conf ~/.tmux.conf
ln -s ${DIR}/.vimrc ~/.vimrc
ln -s ${DIR}/.gitconfig ~/.gitconfig

sudo cp ${DIR}/30-touchpad.conf /etc/X11/xorg.conf.d/

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
