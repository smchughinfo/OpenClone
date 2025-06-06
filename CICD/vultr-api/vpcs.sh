#!/bin/bash

source /vultr-api/api-base.sh

vpcs_endpoint="vpcs"

get_vpcs() {
    vpcs=$(get_vultr "$vpcs_endpoint")
    echo "$vpcs" | jq -r '.vpcs[].id'
}

delete_all_vpcs() {
    local vpc_ids=$(get_vpcs)
    
    # Check if we have any VPCs
    if [ -z "$vpc_ids" ]; then
        echo "No VPCs found"
        return 0
    fi
    
    # Iterate through each VPC ID
    while IFS= read -r vpc_id; do
        if [ -n "$vpc_id" ]; then
            delete_vpc "$vpc_id"
        fi
    done <<< "$vpc_ids"
}

delete_vpc() {
    local vpc_id="$1"
    echo "Deleting VPC $vpc_id..."
    
    # Make the delete API call
    delete_vultr "$vpcs_endpoint/$vpc_id"
    
    # Wait for actual deletion
    echo "Waiting for VPC $vpc_id to be deleted..."
    while true; do
        # Get current VPC IDs
        local current_vpcs=$(get_vpcs)
        
        # Check if our ID is still in the list
        if echo "$current_vpcs" | grep -q "^$vpc_id$"; then
            echo "VPC $vpc_id still exists, waiting 10 seconds..."
            sleep 10
        else
            echo "VPC $vpc_id successfully deleted!"
            break
        fi
    done
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi