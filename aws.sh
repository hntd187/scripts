#!/bin/bash
set -x 
regex="^(\w+)\s\=\s(.*)$"
if [[ -f ~/.aws/credentials ]]; then
  while read line; do 
    if [[ $line =~ $regex ]]; then
      name=$(echo ${BASH_REMATCH[1]} | tr '[:lower:]' '[:upper:]')
      val=${BASH_REMATCH[2]}
      export $name=$val;
    fi
  done < ~/.aws/credentials
fi
