#!/bin/bash

num_col=200
cols=$((${num_col} / 5))

hor_bar='─'
vert_bar='│'
left_joint='├'
right_joint='┤'
col_joint='┴'
top_left='┌'
top_right='┐'
bot_left='└'
bot_right='┘'
mid_sep='┼'
top_sep='┬'

v="\"$vert_bar\""
h="\"$hor_bar\""
b=$(tput bold)
n=$(tput sgr0)

hr() {
  local sep=$1
  local line=$hor_bar
  local tcols=${COLUMNS:-${num_col}}
  local i=1
  while ((${#line} < tcols)); do 
    line+="$hor_bar";
    i=$(($i + 1))
    if (( $i % ($cols - 1) == 0 )); then 
      if (( $i + 5 == $num_col )); then
        line+=$hor_bar
      else
        line+=$sep; 
      fi
    fi
  done
  
  printf '%s%s%s' $start ${line:0:tcols} $end
}

shopt -s lastpipe
lines=[]
apt list --upgradable 2>/dev/null | tail -n+2 | readarray -t lines
shopt -u lastpipe
headers=( "Package" "Repository" "Old Version" "New Version" )

if [[ ${#lines[@]} == 0 ]]; then
  echo "┌─────────────────────────┐" | toilet --gay -t --font term
  echo "│     $b OH NO ALERT!$n       │" | toilet --gay -t --font term
  echo "├─────────────────────────┤" | toilet --gay -t --font term
  echo "│ No updates right now :( │" | toilet --gay -t --font term
  echo "└─────────────────────────┘" | toilet --gay -t --font term
  exit 0;
fi

printf $top_left
hr $top_sep 
printf "$top_right\n"

for h in "${headers[@]}"; do
  s=${#h}
  cc=$((($cols - $s) / 2))
  if [[ $(( $s % 2 )) -eq 0 ]]; then
    ccr=$(( $cc - 1 ))
  else
    ccr=$(( $cc ))
  fi
  printf "%s%${cc}s%s%${ccr}s" $vert_bar "" "${b}$h${n}" "";
done

cc=$((($cols - 3) / 2))
if [[ $(( 4 % 2 )) -eq 0 ]]; then
  ccr=$(( $cc ))
else
  ccr=$(( $cc - 1 ))
fi
printf "%s%${cc}s%s%${ccr}s%s\n" $vert_bar "" "${b}Arch${n}" "" $vert_bar;
printf $left_joint
hr $mid_sep
printf "$right_joint\n"

for v in "${lines[@]}"; do
  IFS=' ' read pkg new arch old <<< "$v"
  repos=${pkg##*/}
  first_repo=${repos##*,}
  old_v=${old##* }
  name=${pkg%%/*}
  line=( $name $first_repo ${old_v:0:-1} $new )
  for col in "${line[@]}"; do
    s=${#col}
    cc=$((($cols - $s) / 2))
    tt=$s
    if [[ $(( $s % 2 )) -eq 0 ]]; then
      ccr=$(( $cc - 1 ))
    else
      ccr=$(( $cc ))
    fi
    printf "%s%${cc}s%s%${ccr}s" $vert_bar "" $col "";
  done
  s=${#arch}
  cc=$(( ($cols - $s) / 2 ))
  if [[ $(( $s % 2 )) -eq 0 ]]; then
    ccr=$(( $cc - 1 ))
  else
    ccr=$(( $cc + 1))
  fi
  printf "%s%${cc}s%s%${ccr}s%s\n" $vert_bar "" $arch "" $vert_bar;
done

printf $bot_left
hr $col_joint 
printf "$bot_right\n"
