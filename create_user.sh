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

# Check if the input file is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE="$1"

# Read the input file and process each line
while IFS=';' read -r username groups; do
    # Remove leading/trailing whitespace
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)

    # Check if user already exists
    if id -u "$username" >/dev/null 2>&1; then
        echo "User $username already exists. Skipping..." | sudo tee -a "$LOG_FILE"
        continue
    fi

    # Split groups by comma
    IFS=',' read -ra group_array <<< "$groups"

    for group in "${group_array[@]}"; do
        # Check if the group exists
        if getent group "$group" >/dev/null 2>&1; then
            # Group exists, add user to group
            sudo useradd -m -g "$group" -s /bin/bash "$username"
            echo "$username added to existing group $group." | sudo tee -a "$LOG_FILE"
        else
            # Group does not exist, create it
            sudo groupadd "$group"
            echo "Group $group created." | sudo tee -a "$LOG_FILE"
            # Create user and add to the new group
            sudo useradd -m -g "$group" -s /bin/bash "$username"
            echo "User $username created with new group $group." | sudo tee -a "$LOG_FILE"
        fi
    done

    # Generate and set password
    password=$(generate_password)
    echo "$username:$password" | sudo chpasswd
    echo "Password set for $username." | sudo tee -a "$LOG_FILE"

    # Set permissions for home directory
    sudo chmod 700 "/home/$username"
    sudo chown "$username:$username" "/home/$username"
    echo "Home directory permissions set for $username." | sudo tee -a "$LOG_FILE"

    # Store password securely
    echo "$username,$password" | sudo tee -a "$PASSWORD_FILE" >/dev/null
    echo "Password stored securely for $username." | sudo tee -a "$LOG_FILE"

done < "$INPUT_FILE"

echo "User creation process completed." | sudo tee -a "$LOG_FILE"
exit 0
