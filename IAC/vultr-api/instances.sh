#!/bin/bash

source /vultr-api/api-base.sh
source /vultr-api/regions.sh

instances_endpoint="instances"

get_instances() {
    i=$(get_vultr "$instances_endpoint")
    echo "$i"
}

get_instance() {
    instance_id="$1"
    i=$(get_vultr "$instances_endpoint/$instance_id")
    echo "$i"
}

get_instance_by_label() {
    label="$1"
    instances=$(get_instances)
    
    # Extract the instance with matching label using jq
    instance=$(echo "$instances" | jq -r --arg label "$label" '.instances[] | select(.label == $label)')
    
    # Check if instance was found
    if [ -z "$instance" ] || [ "$instance" = "null" ]; then
        echo "Instance with label '$label' not found" >&2
        return 1
    fi
    
    echo "$instance"
}

create_instance_from_snapshot() {
    snapshot_id="$1"
    server_0_delta_plan=$(get_cheapest_server_0_delta_plan)
    echo "Using server 0 delta plan: $server_0_delta_plan with snapshot id: $snapshot_id" >&2

    json_data=$(jo \
        label="Server-0-Delta"                          \
        region="$vultr_region"                          \
        plan="$server_0_delta_plan"                     \
        snapshot_id="$snapshot_id"
    )

    echo -e "Creating Server 0 Delta:\n$json_data" >&2
    response=$(post_vultr "$instances_endpoint" "$json_data")
    
    instance_id=$(echo "$response" | jq -r '.instance.id')
    default_password=$(echo "$response" | jq -r '.instance.default_password')
    main_ip=$(echo "$response" | jq -r '.instance.main_ip')
    internal_ip=$(echo "$response" | jq -r '.instance.internal_ip')
    
    echo -e "\nInstance created!" >&2
    echo "Instance ID: $instance_id" >&2
    echo "Default Password: $default_password" >&2
    echo "Main IP: $main_ip" >&2
    echo "Internal IP: $internal_ip" >&2
    
    while [ "$main_ip" = "0.0.0.0" ] || [ -z "$main_ip" ] || [ "$main_ip" = "null" ]; do
        echo "Waiting for IP address assignment..." >&2
        sleep 5
        instance_info=$(get_instance "$instance_id")
        main_ip=$(echo "$instance_info" | jq -r '.instance.main_ip')
    done

    echo "Main IP assigned: $main_ip" >&2
    server_status=$(echo "$instance_info" | jq -r '.instance.server_status')
    while [ "$server_status" != "ok" ]; do
        echo "Waiting for server to finish booting (status: $server_status)..." >&2

        sleep 5
        instance_info=$(get_instance "$instance_id")
        server_status=$(echo "$instance_info" | jq -r '.instance.server_status')
    done

    final_password=$(echo "$instance_info" | jq -r '.instance.default_password')
    if [ -n "$final_password" ] && [ "$final_password" != "null" ]; then
        default_password="$final_password"
    fi

    echo "Final details:" >&2
    echo "Instance ID: $instance_id" >&2
    echo "Default Password: $default_password" >&2
    echo "Main IP: $main_ip" >&2

    # Only this line goes to stdout:
    echo "$instance_id|$default_password|$main_ip"
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi