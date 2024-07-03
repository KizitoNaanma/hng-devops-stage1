#!/bin/bash

# Log file
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Ensure log and password files exist
touch $LOG_FILE
touch $PASSWORD_FILE

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> $LOG_FILE
}

# Function to create a user with specified groups and home directory
create_user() {
    local username="$1"
    local groups="$2"
    local user_group="$username"
    
    # Check if user already exists
    if id "$username" &>/dev/null; then
        log_message "User $username already exists."
        return
    fi

    # Create user group
    if ! getent group "$user_group" > /dev/null 2>&1; then
        groupadd "$user_group"
        log_message "Group $user_group created."
    fi

    # Create user with home directory and primary group
    useradd -m -g "$user_group" -G "$groups" "$username"
    log_message "User $username created with groups $user_group, $groups."

    # Set permissions for home directory
    chmod 700 /home/"$username"
    chown "$username":"$user_group" /home/"$username"
    log_message "Set permissions for /home/$username."

    # Generate random password and set it
    local password=$(openssl rand -base64 12)
    echo "$username:$password" | chpasswd
    log_message "Password set for user $username."

    # Save the password securely
    echo "$username:$password" >> $PASSWORD_FILE
    log_message "Password saved for user $username."
}

# Main script logic
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <user_file>"
    exit 1
fi

USER_FILE="$1"

if [[ ! -f "$USER_FILE" ]]; then
    echo "User file $USER_FILE does not exist."
    exit 1
fi

# Read user file and create users
while IFS=';' read -r user groups; do
    # Remove leading and trailing whitespace
    user=$(echo "$user" | xargs)
    groups=$(echo "$groups" | xargs | tr ',' ' ')
    
    if [[ -n "$user" ]]; then
        create_user "$user" "$groups"
    fi
done < "$USER_FILE"

log_message "User creation process completed."

exit 0
