#!/bin/bash

source /vultr-api/api-base.sh

os_endpoint="os"

# List available operating systems
list_os() {
    os=$(get_vultr "$os_endpoint")
    echo "$os"
}

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi