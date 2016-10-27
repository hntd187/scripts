#!/bin/bash

# If an interactive prompt continue, otherwise stop executing this.
case $- in
    *i*) ;;
      *) return;;
esac

PS1='\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\]: \[\e[1;32m\]\$ \[\e[m\]\[\e[1;37m\]➜ \[\033[0m\]'

# Source aliases if they exist...
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export TERM=xterm-256color
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
export SPARK_LOCAL_IP=$(mip)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/apps/hadoop/lib/native

if [[ -e ~/aws.sh ]]; then
  source ~/aws.sh
fi

# Colored Man Pages, which are fantastic
man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
      man "$@"
}

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s histappend
shopt -s checkwinsize
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi  
fi
