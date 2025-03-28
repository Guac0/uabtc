#!/bin/bash

# Usage: ./exclude_users_password_script.sh <users to exclude from password change separated by spaces>

# Array of users to exclude from lock
excluded_from_lock=("goon1" "goon2" "hacker" "buyer" "lockpick" "safecracker" "root" "blackteam" "sync")

# Array of users to exclude from pw change provided by command args
excluded_pw_users=("$@")

# Array of users to include in lock function and copies to array for pw function
mapfile -t users_to_lock < <(awk -F: '$7 !~ /(nologin|false)/ {print $1}' /etc/passwd)
pw_users=("${users_to_lock[@]}")

# Locks all users in $lock_users
lock_users () {
        for user in "${users_to_lock[@]}"
        do
                if passwd -l "$user" >/dev/null 2>&1; then
                        echo "Account locked for: $user"
                else
                        echo "Failed to lock user: $user"
                fi
        done
}

# First parameter is new password to use
change_passwords () {
        for user in "${pw_users[@]}"
        do
                echo "$user:$1" | chpasswd
                if [ $? -eq 0 ]; then
                        echo "Password changed for user: $user"
                else
                        echo "Failed to change password for user: $user"
                fi
        done
}

exclude_from_lock () {
        local temp_users=()
        for user in "${users_to_lock[@]}"
        do
                if [[ "${excluded_from_lock[@]}" =~ "$user" ]]; then
                        echo "Removing user from lock list: $user"
                else
                        temp_users+=("$user")
                fi
        done
        users_to_lock=("${temp_users[@]}")
}

exclude_from_pw_change () {
        local temp_users=()
        for user in "${pw_users[@]}"
        do
                if [[ "${excluded_pw_users[@]}" =~ "$user" ]]; then
                        echo "Removing user from password change list: $user"
                else
                        temp_users+=("$user")
                fi
        done
        pw_users=("${temp_users[@]}")
}

confirm_changes () {
        echo "The following usres will have their passwords changed:"
        for user in "${pw_users[@]}"
        do
                echo "- $user"
        done
        echo
        echo "The following users will be locked:"
        for user in "${users_to_lock[@]}"
        do
                echo "- $user"
        done

        # Ask for confirmation
        read -p "Do you want to proceed? (y/n): " confirm
        if [ ! "$confirm" == "y" ]; then
                echo "Changes cancelled. Exiting..."
                exit 0
        fi
}

# Main

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root. Exiting..."
        exit 1
fi

read -sp "Enter the new password: " password
echo
read -sp "Confirm the new password: " password_confirm
echo

# Ensure passwords match
if [ "$password" != "$password_confirm" ]; then
        echo "Passwords do not match! Exiting..."
        exit 1
fi

exclude_from_pw_change
exclude_from_lock

confirm_changes

change_passwords "$password"
lock_users

