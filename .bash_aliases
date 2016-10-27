#!/bin/bash

alias ll='LC_ALL="C" ls -GlAh --group-directories-first --color=always'
alias la='ls -Ah'
alias l='ls -CFh'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias mip='route -n | grep "^0.0.0.0" | head -1 | tr -s " " | grep -o "[^ ]*$" | xargs -I{} ip -4 -o addr show dev {} | tr -s " " | awk -F" " "{print \$4}"'
