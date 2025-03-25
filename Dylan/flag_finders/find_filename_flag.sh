#!/bin/bash

# Usage: ./find_filename_flag.sh <directory_to_search>

# If no directory is specified, show usage
if [ -z "$1" ]; then
	echo "Usage: $0 <directory_to_search>"
	exit 1
fi

directory="$1" # The directory to search
pattern=".*\/\w+'?\w-\w+'?\w-\w+'?\w" # The pattern to search for

# Finds files with matching pattern
find $directory -regextype egrep -regex "$pattern"