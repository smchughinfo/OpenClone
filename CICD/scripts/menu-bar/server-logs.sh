#!/bin/bash

source /scripts/shell-helpers/aliases.sh

get_pod_names() {
    local resource_type=$1
    local resource_name=$2

    # Retrieve pod names for the given resource type (deployment/statefulset) and name
    pod_names=($(k get pods -l "app=$resource_name" --no-headers | awk '{print $1}'))
}

print_logs() {
    local resource_type=$1  # Type: deployment or statefulset
    local resource_name=$2  # Name of the deployment or statefulset

    echo "Fetching pod names for $resource_type: $resource_name"

    # Call the get_pod_names function to populate the pod_names array
    get_pod_names "$resource_type" "$resource_name"

    if [[ ${#pod_names[@]} -eq 0 ]]; then
        echo "No pods found for $resource_type: $resource_name"
        return
    fi

    # Print all matching pod names and their logs
    echo "Matching pod names for $resource_type: $resource_name"
    for pod in "${pod_names[@]}"; do
        echo "$pod"
        echo "Fetching logs for pod: $pod"
        k logs "$pod"
        echo "--------------------------------------------------"
    done
}
