# User Management Script

This script automates the process of creating users and managing their groups on a Unix-based system. It reads user and group information from an input file, creates users if they don't exist, adds them to existing or new groups, sets passwords, manages permissions, and securely stores passwords.

## Features

- **User Creation**: Checks if a user exists; if not, creates the user.
- **Group Management**: Checks if groups exist; if not, creates them.
- **Password Management**: Generates random passwords and securely stores them.
- **Permissions**: Sets appropriate permissions for user home directories.
- **Logging**: Logs all actions and outcomes to a specified log file (`/var/log/user_management.log`).

## Prerequisites

- Unix-like environment (tested on Linux).
- `sudo` privileges to execute administrative commands (`useradd`, `groupadd`, etc.).
- Input file containing user and group information.

## Usage

1. **Clone the Repository**:

   ```bash
   git clone https:github.com/KizitoNaanma/hng-devops-stage1.git
   cd hng-devops-stage1
   
2. **Prepare txt file**: (`users.txt`)
   ``` text
    light; sudo,dev,www-data
    idimma; sudo
    mayowa; dev,www-data
   
3. **Execute**:
   ```bash
   bash create_user.sh users.txt
   ```
   
  
