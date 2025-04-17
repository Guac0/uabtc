#!/bin/bash

while true; do
  read -ra args -p "$(whoami)@$(hostname):$(pwd)\$ "
  echo "${args[@]}" >> bass.log
  if [[ "${args[0]}" == "ls" ]]; then
    for ((i = 1; i < ${#args[@]}; i++)); do
      if [[ "${args[i]}" == -* ]]; then
        continue
      fi
      echo "ls: cannot access '${args[i]}': No such file or directory"
    done
  fi
done
