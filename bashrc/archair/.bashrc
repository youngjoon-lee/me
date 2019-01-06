#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

set -o vi

alias ls='ls --color=auto'
alias ll='ls -l'
alias vi='vim'

export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

export PS1="[\[\033[36m\]\u\[\033[31m\]@\[\033[32m\]\h \[\033[33;1m\]\W\[\033[m\]]\$ "

export PATH="$PATH:$HOME/go/bin"
