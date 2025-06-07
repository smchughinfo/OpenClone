#!/bin/bash

source /vultr-api/api-base.sh

vpcs_endpoint="vpcs"

# Configuration
MAX_RETRIES=3
RETRY_DELAY=5
DELETION_CHECK_INTERVAL=5
DELETION_TIMEOUT=15 

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
    
    local failed_vpcs=()
    
    # Iterate through each VPC ID
    while IFS= read -r vpc_id; do
        if [ -n "$vpc_id" ]; then
            if ! delete_vpc "$vpc_id"; then
                failed_vpcs+=("$vpc_id")
            fi
        fi
    done <<< "$vpc_ids"
    
    # Report results
    if [ ${#failed_vpcs[@]} -eq 0 ]; then
        echo "All VPCs deleted successfully"
        return 0
    else
        echo "Failed to delete the following VPCs: ${failed_vpcs[*]}"
        return 1
    fi
}

delete_vpc() {
    local vpc_id="$1"
    local attempt=1
    
    echo "Deleting VPC $vpc_id..."
    
    # Retry loop for the delete operation
    while [ $attempt -le $MAX_RETRIES ]; do
        echo "Attempt $attempt of $MAX_RETRIES for VPC $vpc_id"
        
        # Make the delete API call
        if delete_vultr "$vpcs_endpoint/$vpc_id"; then
            # API call succeeded, now wait for actual deletion
            if wait_for_vpc_deletion "$vpc_id"; then
                echo "VPC $vpc_id successfully deleted!"
                return 0
            else
                echo "VPC $vpc_id deletion timed out"
                return 1
            fi
        else
            # API call failed
            echo "Delete API call failed for VPC $vpc_id"
            
            if [ $attempt -lt $MAX_RETRIES ]; then
                echo "Retrying in $RETRY_DELAY seconds..."
                sleep $RETRY_DELAY
            fi
        fi
        
        ((attempt++))
    done
    
    echo "Failed to delete VPC $vpc_id after $MAX_RETRIES attempts"
    return 1
}

wait_for_vpc_deletion() {
    local vpc_id="$1"
    local elapsed=0
    
    echo "Waiting for VPC $vpc_id to be deleted..."
    
    while [ $elapsed -lt $DELETION_TIMEOUT ]; do
        # Get current VPC IDs
        local current_vpcs=$(get_vpcs)
        
        # Check if our ID is still in the list
        if echo "$current_vpcs" | grep -q "^$vpc_id$"; then
            echo "VPC $vpc_id still exists, waiting $DELETION_CHECK_INTERVAL seconds... (${elapsed}s elapsed)"
            sleep $DELETION_CHECK_INTERVAL
            ((elapsed += DELETION_CHECK_INTERVAL))
        else
            echo "VPC $vpc_id confirmed deleted after ${elapsed}s"
            return 0
        fi
    done
    
    echo "Timeout waiting for VPC $vpc_id deletion after ${DELETION_TIMEOUT}s"
    return 1
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi