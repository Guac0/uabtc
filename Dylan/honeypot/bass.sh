#!/bin/bash

while true; do
  if [[ "$1" == "ls" ]]; then
    shift 1
    args="$@"
    for arg in $args; do
      echo "ls: cannot access '$arg': No such file or directory"
    done
  fi
done
