#!/bin/bash

# Function to generate a random name
generate_random_name() {
    FIRST_NAMES=("John" "Jane" "Alice" "Bob" "Charlie" "David" "Eve" "Frank" "Grace" "Helen")
    LAST_NAMES=("Smith" "Johnson" "Brown" "Williams" "Jones" "Miller" "Davis" "García" "Rodriguez" "Martinez")

    # Pick random first and last names
    FIRST_NAME=${FIRST_NAMES[$RANDOM % ${#FIRST_NAMES[@]}]}
    LAST_NAME=${LAST_NAMES[$RANDOM % ${#LAST_NAMES[@]}]}

    # Combine to make a full name
    echo "$FIRST_NAME$LAST_NAME"
}

# Set default password
DEFAULT_PASSWORD="DefaultPass1#"

# Loop to create 20 users
for i in {1..20}; do
    USERNAME=$(generate_random_name)

    # Create the user with the default password
    sudo useradd -m -s /bin/bash -p "$(openssl passwd -1 $DEFAULT_PASSWORD)" $USERNAME
    
    # Randomly decide if the user should be in the sudo group
    if (( RANDOM % 2 == 0 )); then
        sudo usermod -aG sudo $USERNAME
        echo "Created user $USERNAME and added to sudo group."
    else
        echo "Created user $USERNAME."
    fi
done

# Define users
users=("goon1" "goon2" "hacker")
admins=("buyer" "lockpick" "safecracker" "blackteam")

# Create standard users
for user in "${users[@]}"; do
    sudo useradd -m -s /bin/bash "$user"
    echo "$user:DEFAULT_PASSWORD" | sudo chpasswd
    echo "User $user created."
done

# Create admin users
for admin in "${admins[@]}"; do
    sudo useradd -m -s /bin/bash "$admin"
    echo "$admin:$DEFAULT_PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo "$admin"
    echo "Admin $admin created and added to sudo group."
done

#sudo useradd -m -s /bin/bash redteam
#echo "redteam:letredin" | sudo chpasswd
#sudo usermod -aG sudo redteam

echo "Users and admins have been created successfully."