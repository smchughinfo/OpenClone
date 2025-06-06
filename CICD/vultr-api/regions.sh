#!/bin/bash

source /vultr-api/api-base.sh
source /vultr-api/registries.sh
source /vultr-api/plans.sh
source /scripts/shell-helpers/aliases.sh

region_endpoint="regions"

list_regions() {
    get_vultr "$region_endpoint"
}

list_plans_in_region() {
    local region_id=$1

    # Check if region_id is provided
    if [ -z "$region_id" ]; then
        echo "Error: region_id is required."
        return 1
    fi

    # Get the list of available plans in the region
    plans_in_region=$(get_vultr "$region_endpoint/$region_id/availability")
    if [ -z "$plans_in_region" ]; then
        echo "Error: Failed to retrieve plans in region $region_id."
        return 1
    fi

    # Get all plan details
    plan_details=$(list_plans)
    if [ -z "$plan_details" ]; then
        echo "Error: Failed to retrieve plan details."
        return 1
    fi

    # Filter plan_details to only include plans in available_plans
    filtered_plans=$(echo "$plan_details" | jq --argjson available_plans "$(echo "$plans_in_region" | jq '.available_plans')" '
        .plans | map(select(.id as $id | $available_plans | index($id)))
    ')
    if [ -z "$filtered_plans" ]; then
        echo "Error: Failed to filter plans."
        return 1
    fi

    # Output the filtered plans
    echo "$filtered_plans"
}

filter_plans_in_region() {
    local type="$1"
    local min_cpus="$2"
    local min_ram="$3"
    local min_hdd="$4"
    local gpu_type="$5"     # optional: e.g., "NVIDIA_L40S", "NVIDIA_A16"
    local min_gpu_ram="$6"  # optional: minimum GPU VRAM in GB

    # Get the list of plans available in the region
    plans_in_region=$(list_plans_in_region "$vultr_region")

    # Build jq filter conditions
    local conditions=()
    
    # Add type filter if specified
    if [ -n "$type" ] && [ "$type" != "any" ]; then
        conditions+=("(.type == \$type)")
    fi
    
    # Add CPU filter if specified
    if [ -n "$min_cpus" ] && [ "$min_cpus" -gt 0 ]; then
        conditions+=("(.vcpu_count >= \$min_cpus)")
    fi
    
    # Add RAM filter if specified
    if [ -n "$min_ram" ] && [ "$min_ram" -gt 0 ]; then
        conditions+=("(.ram >= \$min_ram)")
    fi
    
    # Add disk filter if specified
    if [ -n "$min_hdd" ] && [ "$min_hdd" -gt 0 ]; then
        conditions+=("(.disk >= \$min_hdd)")
    fi
    
    # Add GPU type filter if specified (only for GPU plans)
    if [ -n "$gpu_type" ] && [ "$gpu_type" != "any" ]; then
        conditions+=("(.gpu_type == \$gpu_type)")
    fi
    
    # Add GPU VRAM filter if specified (only for GPU plans)
    if [ -n "$min_gpu_ram" ] && [ "$min_gpu_ram" -gt 0 ]; then
        conditions+=("(.gpu_vram_gb >= \$min_gpu_ram)")
    fi
    
    # Build the complete jq filter
    local jq_filter="map(select("
    if [ ${#conditions[@]} -eq 0 ]; then
        jq_filter="${jq_filter}true"
    else
        # Join conditions with " and " manually
        local first=true
        for condition in "${conditions[@]}"; do
            if [ "$first" = true ]; then
                jq_filter="${jq_filter}${condition}"
                first=false
            else
                jq_filter="${jq_filter} and ${condition}"
            fi
        done
    fi
    jq_filter="${jq_filter}))"

    # Filter the plans based on the given criteria
    filtered_plans=$(echo "$plans_in_region" | jq \
        --arg type "$type" \
        --argjson min_cpus "${min_cpus:-0}" \
        --argjson min_ram "${min_ram:-0}" \
        --argjson min_hdd "${min_hdd:-0}" \
        --arg gpu_type "$gpu_type" \
        --argjson min_gpu_ram "${min_gpu_ram:-0}" \
        "$jq_filter")

    if [ -z "$filtered_plans" ]; then
        echo "Error: Failed to filter plans."
        return 1
    fi

    # Output the filtered plans
    echo "$filtered_plans"
}

apply_all() {
    apply_vultr_provider

    start_time=$(date +%s)
    elapsed=0

    echo "Waiting for all nodes to become ready..."

    while true; do
        # Get node statuses, escaping the square brackets
        status=$(k get nodes --field-selector=status.conditions[\?\(@.type==\"Ready\"\)].status==\"True\")

        # Calculate elapsed time
        current_time=$(date +%s)
        elapsed=$((current_time - start_time))

        # Print status and time waited to the log file
        echo "Status: ${status} | Elapsed Time: ${elapsed}s"

        # Break loop if all nodes are ready
        if [[ $(k get nodes --no-headers | wc -l) -eq $(echo "$status" | grep -c ' Ready ') ]]; then
            echo "All nodes are ready."
            break
        fi

        # Wait 5 seconds before next check
        sleep 5
    done

    apply_kubernetes_provider
}

get_cheapest_cpu_node_plan() {
    filter_plans_in_region "vc2" 2 4086 160 | get_cheapest_plan
}

get_cheapest_gpu_node_plan() {
    filter_plans_in_region "vcg" 2 4086 160 "any" 4 | get_cheapest_plan
}

get_cheapest_server_0_delta_plan() {
    #filter_plans_in_region "" 12 32000 160 | get_cheapest_plan
    #filter_plans_in_region "" 6 16000 160 | get_cheapest_plan
    filter_plans_in_region "vc2" 2 4086 160 | get_cheapest_plan
}

get_cheapest_plan() {
    local plans=$(cat)  # Read from stdin
    
    # Check if we have any plans
    if [ -z "$plans" ] || [ "$plans" = "[]" ]; then
        echo "Error: No plans found to compare"
        return 1
    fi

    local cheapest_price=9999999
    local cheapest_plan_id=""

    num_plans=$(echo "$plans" | jq 'length')
    for (( i=0; i<$num_plans; i++ )); do
        plan=$(echo "$plans" | jq ".[$i]")
        plan_id=$(get_plan_id "$plan")
        monthly_cost=$(echo "$plan" | jq -r '.monthly_cost')

        if [ "$(echo "$monthly_cost $cheapest_price" | awk '{print ($1 < $2)}')" = "1" ]; then
            cheapest_price="$monthly_cost"
            cheapest_plan_id="$plan_id"
        fi
        
    done

    echo "$cheapest_plan_id"
}

###################################################################
######## HELPERS ##################################################
###################################################################

get_plan_id() {
    local plan_json="$1"
    plan_id=$(echo "$plan_json" | jq -r '.id')
    echo "$plan_id"
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi
