[[ $TERM != "screen" ]] && exec tmux

TERM=rxvt-unicode-256color
HADOOP=$(readlink -f $(which hadoop))
JAVA=$(readlink -f $(which javac))
export JAVA_HOME=${JAVA%/*/*}
export HADOOP_HOME=${HADOOP%/*/*}
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native
export SPARK_LOCAL_IP=$(ifconfig $(route | grep 'default' | awk '{if ($8 ~ /eth[0-9]+/){ print $8 }}') | grep "inet " | awk '{print $2}' | cut -d: -f2)
export EDITOR=vim
AWS_CONFIG=~/.aws/credentials
if [[ -r $AWS_CONFIG ]]; then
  ACCESS_KEY=$(cat $AWS_CONFIG | grep '^aws_access_key_id' | grep -o '[A-Z0-9]*')
  SECRET_KEY=$(cat $AWS_CONFIG | grep '^aws_secret_access_key' | grep -Eo '[0-9a-zA-Z\/+=]{40}')
fi
export AWS_ACCESS_KEY_ID=$ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$SECRET_KEY

case $- in
    *i*) ;;
      *) return;;
esac
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

PS1='\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\]: \[\e[1;32m\]\$ \[\e[m\]\[\e[1;37m\]➜ \[\033[0m\]'
case "$TERM" in
    xterm*|rxvt*) 
      color_prompt=yes
      ;;
esac
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
alias ll='ls -lF'
alias la='ls -A'
alias l='ls -CF'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
