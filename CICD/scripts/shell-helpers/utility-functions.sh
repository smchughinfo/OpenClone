#!/bin/bash

set_env_variable() {
    local var_name="$1"
    local var_value="$2"
    local scope="${3:-user}"  # user, global, or system
    local file

    case "$scope" in
        "global"|"system")
            # System-wide environment variables
            file="/etc/environment"
            
            # Check if we have root privileges
            if [ "$EUID" -ne 0 ]; then
                echo "Error: Root privileges required for global environment variables"
                echo "Run with sudo or switch scope to 'user'"
                return 1
            fi
            
            # Handle /etc/environment format (no 'export' keyword)
            if grep -q "^$var_name=" "$file" 2>/dev/null; then
                # Update existing variable
                sudo sed -i "s|^$var_name=.*|$var_name=\"$var_value\"|" "$file"
            else
                # Add new variable
                echo "$var_name=\"$var_value\"" | sudo tee -a "$file" > /dev/null
            fi
            
            # Also add to /etc/bash.bashrc for immediate shell availability
            local bashrc_file="/etc/bash.bashrc"
            local export_line="export $var_name=\"$var_value\""
            
            if grep -q "^export $var_name=" "$bashrc_file" 2>/dev/null; then
                sudo sed -i "s|^export $var_name=.*|$export_line|" "$bashrc_file"
            else
                echo "$export_line" | sudo tee -a "$bashrc_file" > /dev/null
            fi
            
            echo "Global environment variable $var_name set to $var_value"
            ;;
            
        "user")
            # User-specific environment variables
            file="$HOME/.bashrc"
            
            if grep -q "^export $var_name=" "$file"; then
                # Update the existing variable
                sed -i "s|^export $var_name=.*|export $var_name=\"$var_value\"|" "$file"
            else
                # Add a new variable
                echo "export $var_name=\"$var_value\"" >> "$file"
            fi
            
            echo "User environment variable $var_name set to $var_value"
            ;;
            
        *)
            echo "Error: Invalid scope '$scope'. Use 'user', 'global', or 'system'"
            return 1
            ;;
    esac

    # Apply the changes immediately to current session
    export "$var_name=$var_value"
    
    echo "Environment variable $var_name set to $var_value and persisted ($scope scope)."
}

# Enhanced version that can set multiple variables at once
set_env_variables_bulk() {
    local scope="${1:-user}"
    shift  # Remove scope from arguments
    
    echo "Setting environment variables with scope: $scope"
    
    # Process variable pairs (name value name value ...)
    while [ $# -gt 1 ]; do
        set_env_variable "$1" "$2" "$scope"
        shift 2
    done
}

# Function to remove environment variables
remove_env_variable() {
    local var_name="$1"
    local scope="${2:-user}"
    local file
    
    case "$scope" in
        "global"|"system")
            if [ "$EUID" -ne 0 ]; then
                echo "Error: Root privileges required for global environment variables"
                return 1
            fi
            
            # Remove from /etc/environment
            sudo sed -i "/^$var_name=/d" /etc/environment
            
            # Remove from /etc/bash.bashrc
            sudo sed -i "/^export $var_name=/d" /etc/bash.bashrc
            
            echo "Removed global environment variable: $var_name"
            ;;
            
        "user")
            sed -i "/^export $var_name=/d" "$HOME/.bashrc"
            echo "Removed user environment variable: $var_name"
            ;;
    esac
    
    # Remove from current session
    unset "$var_name"
}

# Function to list environment variables by scope
list_env_variables() {
    local scope="${1:-all}"
    
    case "$scope" in
        "global"|"system")
            echo "=== Global Environment Variables ==="
            if [ -f /etc/environment ]; then
                cat /etc/environment
            else
                echo "No global environment file found"
            fi
            ;;
            
        "user")
            echo "=== User Environment Variables ==="
            grep "^export " "$HOME/.bashrc" 2>/dev/null || echo "No user environment variables found"
            ;;
            
        "current")
            echo "=== Current Session Variables ==="
            env | grep -E '^(TF_VAR_|CICD_|OpenClone_|KUBE)' | sort
            ;;
            
        "all")
            list_env_variables "global"
            echo ""
            list_env_variables "user" 
            echo ""
            list_env_variables "current"
            ;;
    esac
}

# Your existing functions (keeping them as-is)
ensure_success() {
    "$@"
    if [ $? -ne 0 ]; then
        echo "Command failed: $@. Exiting."
        exit 1
    fi
}

remove_if_exists() {
    if [ -e "$1" ]; then
        rm -rf "$1"
        echo "$1 was deleted."
    else
        echo "$1 does not exist (nothing to delete)."
    fi
}