# hng-devops-stage1

# User Management Script

## Overview

`create_users.sh` is a Bash script designed to automate the process of creating users and groups on a Linux system. The script reads a text file containing usernames and group names, creates users and their associated groups, sets up home directories with appropriate permissions, generates random passwords for the users, and logs all actions. Generated passwords are securely stored.

## Features

- Creates users and their personal groups.
- Assigns additional groups to users as specified.
- Sets up home directories with appropriate permissions and ownership.
- Generates random passwords for users and securely stores them.
- Logs all actions to `/var/log/user_management.log`.

## Requirements

- Bash
- OpenSSL (for generating random passwords)
- Root privileges to create users and groups, and modify system files

## Usage

### 1. Script Setup

Ensure the script is executable:
```sh
chmod +x create_users.sh
```

### 2. Execute
```sh
sudo ./create_users.sh user_file.txt
