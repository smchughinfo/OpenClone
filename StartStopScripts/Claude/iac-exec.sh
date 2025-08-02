#\!/bin/bash

# IAC Container Command Executor
# Allows Claude to execute commands inside the IAC dev container

if [ $# -eq 0 ]; then
    echo "Usage: $0 <command>"
    echo "Example: $0 'k get pods'"
    exit 1
fi

COMMAND="$1"

# Execute command in IAC container and capture output
docker exec openclone-iac bash -c "cd /workspaces/IAC && $COMMAND"
