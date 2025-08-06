#!/bin/bash

source /vultr-api/api-base.sh

loadbalancers_endpoint="load-balancers"

get_loadbalancers() {
    lb=$(get_vultr "$loadbalancers_endpoint")
    echo "$lb" | jq -r '.load_balancers[].id'
}

delete_all_loadbalancers() {
    local lb_ids=$(get_loadbalancers)
    
    # Check if we have any load balancers
    if [ -z "$lb_ids" ]; then
        echo "No load balancers found"
        return 0
    fi
    
    # Iterate through each load balancer ID
    while IFS= read -r lb_id; do
        if [ -n "$lb_id" ]; then
            delete_loadbalancer "$lb_id"
        fi
    done <<< "$lb_ids"
}

delete_loadbalancer() {
    local lb_id="$1"
    echo "Deleting load balancer $lb_id..."
    
    # Make the delete API call
    delete_vultr "$loadbalancers_endpoint/$lb_id"
    
    # Wait for actual deletion
    echo "Waiting for load balancer $lb_id to be deleted..."
    while true; do
        # Get current load balancer IDs
        local current_lbs=$(get_loadbalancers)
        
        # Check if our ID is still in the list
        if echo "$current_lbs" | grep -q "^$lb_id$"; then
            echo "Load balancer $lb_id still exists, waiting 10 seconds..."
            sleep 10
        else
            echo "Load balancer $lb_id successfully deleted!"
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