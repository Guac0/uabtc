#!/bin/bash

while true; do
  read -ra args -p "$(whoami)@$(hostname):$(pwd)\$ "
  if [[ "${args[0]}" == "ls" ]]; then
    for ((i = 1; i < ${#args[@]}; i++)); do
      echo "ls: cannot access '${args[i]}': No such file or directory"
    done
  fi
done
