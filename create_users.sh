#!/bin/bash

# Log file and password storage
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Ensure the log file and password file exist with the right permissions
sudo touch "$LOG_FILE" >/dev/null 2>&1
sudo mkdir -p $(dirname "$PASSWORD_FILE") >/dev/null 2>&1
sudo touch "$PASSWORD_FILE" >/dev/null 2>&1
sudo chmod 600 "$PASSWORD_FILE"

# Function to generate a random password
generate_password() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 12
}

# Function to create user and their personal group
create_user_and_group() {
    local username="$1"
    local groups="$2"

    # Check if user already exists
    if id -u "$username" >/dev/null 2>&1; then
        echo "User $username already exists. Skipping..." | sudo tee -a "$LOG_FILE" 
    fi

    # Create personal group if it doesn't exist
    if ! getent group "$username" >/dev/null 2>&1; then
        sudo groupadd "$username"
        echo "Personal group $username created." | sudo tee -a "$LOG_FILE" 
    fi

    # Split groups by comma
    IFS=',' read -ra group_array <<< "$groups"

    for group in "${group_array[@]}"; do
        # Check if the group exists
        if getent group "$group" >/dev/null 2>&1; then
            # Group exists, add user to group
            sudo useradd -m -g "$group" -G "$username" "$username"
            echo "User $username added to existing group $group." | sudo tee -a "$LOG_FILE" 
        else
            # Group does not exist, create it
            sudo groupadd "$group"
            echo "Group $group created." | sudo tee -a "$LOG_FILE" 
            # Create user and add to the new group
            sudo useradd -m -g "$group" -G "$username" "$username"
            echo "User $username created with new group $group." | sudo tee -a "$LOG_FILE" 
        fi
    done

    # Generate and set password
    local password=$(generate_password)
    echo "$username:$password" | sudo chpasswd
    echo "Password set for $username." | sudo tee -a "$LOG_FILE" 

    # Set permissions for home directory
    sudo chmod 700 "/home/$username"
    echo "Home directory permissions set for $username." | sudo tee -a "$LOG_FILE"

    # Store password securely
    echo "$username,$password" | sudo tee -a "$PASSWORD_FILE" >/dev/null
    echo "Password stored securely for $username." | sudo tee -a "$LOG_FILE" 
}

# Check if the input file is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE="$1"

# Read the input file and process each line
while IFS=';' read -r username groups || [[ -n "$username" ]]; do
    # Remove leading/trailing whitespace
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)

    create_user_and_group "$username" "$groups"

done < "$INPUT_FILE"

echo "User creation process completed." | sudo tee -a "$LOG_FILE" 
exit 0
