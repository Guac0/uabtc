#!/bin/bash

#Ask for input for new password and store it in password variable
#-p is for prompt, -s is for silent (Don't show input)
read -ps "Enter your new password: " password

#Get all users that can login and do not have false as a field
#Piped to cut to only return the username
#-d sets a delimiter (colon) -f specifies fields (field 1)
users=$(grep -Ev "nologin|false" /etc/passwd | cut -d: -f1)

#Iterate through the users found and change the password
for user in $users;
do
    passwd $user
    #Here, we echo $password twice because passwd asks you to
    #confirm your password
    echo "$password"
    echo "$password"
done