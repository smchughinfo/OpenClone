#!/bin/bash

# Get the directory of the script and go up one level
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Activate virtual environment
source .venv/bin/activate

# Check for arguments
if [ $# -eq 0 ]; then
    python Main.py restore \
        --openclone_db_super_connection_string "$OpenClone_DefaultConnection_Super" \
        --log_db_super_connection_string "$OpenClone_LogDbConnection_Super" \
        --openclone_db_user_name "$OpenClone_OpenCloneDB_User" \
        --openclone_db_user_password "$OpenClone_OpenCloneDB_Password" \
        --log_db_user_name "$OpenClone_LogDB_User" \
        --log_db_user_password "$OpenClone_LogDB_Password"
else
    # Use "$@" to get all command-line arguments
    echo "using args ---> $@"
    python Main.py restore "$@"
fi