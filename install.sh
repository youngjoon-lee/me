#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

force=0
if [ ! -z ${FORCE} ]; then
	force=${FORCE}
fi

if [ ${force} -eq 1 ]; then
	rm -f ~/.alacritty.yml
fi
ln -s ${SCRIPTPATH}/.alacritty.yml ~/.alacritty.yml

if [ ${force} -eq 1 ]; then
	rm -f ~/.tmux.conf
fi
ln -s ${SCRIPTPATH}/.tmux.conf ~/.tmux.conf

if [ ${force} -eq 1 ]; then
	rm -f ~/.vimrc
fi
ln -s ${SCRIPTPATH}/.vimrc ~/.vimrc

if [ ${force} -eq 1 ]; then
	rm -f ~/.gitconfig
fi
ln -s ${SCRIPTPATH}/.gitconfig ~/.gitconfig

