#!/bin/bash

source /scripts/status-bar.sh
source /scripts/shell-helpers/utility-functions.sh

# Define environment names as constants
ENV_KIND="kind"
ENV_VULTR_DEV="vultr_dev"
ENV_VULTR_PROD="vultr_prod"

switch_environment() {
    local env="$1"

    # If no argument is provided, display a menu
    if [ -z "$env" ]; then
        echo "Please select an environment:"
        echo "1. $ENV_KIND"
        echo "2. $ENV_VULTR_DEV"
        echo "3. $ENV_VULTR_PROD"
        read -p "Enter the number of your choice: " choice
        case "$choice" in
            1) env="$ENV_KIND" ;;
            2) env="$ENV_VULTR_DEV" ;;
            3) env="$ENV_VULTR_PROD" ;;
            *) echo "Invalid choice"; return 1 ;;
        esac
    fi

    # Set the TF_VAR_kube_config_path based on the selected environment
    case "$env" in
        "$ENV_KIND")
            set_env_variable TF_VAR_kube_config_path "$kind_kube_config_path"
            set_statusbar_color "#21272e"
            ;;
        "$ENV_VULTR_DEV")
            set_env_variable TF_VAR_kube_config_path "$vultr_dev_kube_config_path"
            set_statusbar_color "#5A2500"
            ;;
        "$ENV_VULTR_PROD")
            set_env_variable TF_VAR_kube_config_path "$vultr_prod_kube_config_path"
            set_statusbar_color "#961e1e"
            ;;
        *)
            echo "Unknown environment: $env"
            return 1
            ;;
    esac

    set_terraform_workspace $env

    set_statusbar_text "$env"
    echo "Switched to environment: $env"
}

set_terraform_workspace() {
    local env="$1"
    local dir="/terraform"

    if [ -z "$env" ]; then
        echo "Usage: set_terraform_workspace <env> [directory]"
        return 1
    fi

    # Check if the workspace exists
    if terraform -chdir="$dir" workspace list | grep -q "^  $env$"; then
        echo "Switching to existing workspace: $env"
        terraform -chdir="$dir" workspace select "$env"
    else
        echo "Creating and switching to new workspace: $env"
        terraform -chdir="$dir" workspace new "$env"
    fi

    set_env_variable TF_VAR_environment $env
}

get_terraform_environment() {
    if [ "$Server_0_CICD_ENV" == "server-0" ]; then
        echo "$ENV_VULTR_DEV"
        return
    fi

    local env_file="/terraform/.terraform/environment"
    
    if [[ -f "$env_file" ]]; then
        env_value=$(cat "$env_file")
        if [[ "$env_value" == "default" ]]; then
            env_value=$ENV_VULTR_DEV
            echo "$env_value" > "$env_file"
        fi
    fi

    echo "$env_value"
}

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi