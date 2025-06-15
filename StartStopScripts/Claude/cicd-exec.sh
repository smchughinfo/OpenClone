#\!/bin/bash

# CICD Container Command Executor
# Allows Claude to execute commands inside the CICD dev container

if [ $# -eq 0 ]; then
    echo "Usage: $0 <command>"
    echo "Example: $0 'k get pods'"
    exit 1
fi

COMMAND="$1"

# Execute command in CICD container and capture output
docker exec openclone-cicd bash -c "cd /workspaces/CICD && $COMMAND"
EOF < /dev/null
