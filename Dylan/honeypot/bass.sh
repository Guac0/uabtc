#!/bin/bash

trap 'printf "SIGINT caught! Use 'exit' to leave.\n$(whoami)@$(hostname):$(pwd)\$ "' SIGINT

# For testing... Allows exit
exit_real() {
  if [[ "${args[0]}" == "nuh" && "${args[1]}" == "uh" ]]; then
    exit 0
  fi
}

ls() {
  if [[ "${args[0]}" == "ls" ]]; then
    for ((i = 1; i < ${#args[@]}; i++)); do
      if [[ "${args[i]}" == -* ]]; then
        continue
      fi
      echo "ls: cannot access '${args[i]}': No such file or directory"
    done
  fi
}

exit_fake() {
  if [[ "${args[0]}" == "exit" ]]; then
    echo "nuh uh"
  fi
}

while true; do
  read -ra args -p "$(whoami)@$(hostname):$(pwd)\$ "
  echo "${args[@]}" >>bass.log
  exit_real
  ls
  exit_fake
done
