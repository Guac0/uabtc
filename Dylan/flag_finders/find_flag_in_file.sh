#!/bin/bash

# Usage: ./find_flag_in_file.sh <directory_to_search>

# If no directory is specified, show usage
if [ -z "$1" ]; then
	echo "Usage: $0 <directory_to_search>"
	exit 1
fi

directory="$1" # Directory to search
pattern="ISTS{.*}" # Pattern to search for
filesize=25c # Max size of file (Default 25 bytes)

# Message to let the user know the script is running
echo "Searching in '$directory' for pattern: '$pattern'"

# This command finds all files in the specified directory
# then ignores important system directories that might cause issues.
# It specifies the type as file, size to be less than $filesize,
# and separates entries with a null character '\0' to fix filename
# parsing issues. The output is then piped to xargs with -0 to allow
# it to parse the output from the -print0 option and disallows empty
# grep calls (if find returns nothing). Xargs adds every file outputted
# by find to the end of the grep command for grep to make one call on all files.
find "$directory" \
  \( -path /mnt -o -path /dev -o -path /proc -o -path /sys -o -path /run \) -prune -o \
  -type f -size -$filesize -print0 | \
xargs -0r grep -soHE "$pattern"