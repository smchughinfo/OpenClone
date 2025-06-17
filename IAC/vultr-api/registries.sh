#!/bin/bash

source /vultr-api/api-base.sh

registry_endpoint="registry"
registries_endpoint="registries" # for some reason they use this registries as the endpoint sometimes. so sometimes registry, sometimes registries

################################################################################
######## REGISTRY CRUD #########################################################
################################################################################

create_container_registry() {
    name="openclone"
    plan=$(get_cheapest_registry_plan 51200)
    region="$vultr_region"

    json_data=$(jo name="$name" public=false region="$region" plan="$plan")
    post_vultr "$registry_endpoint" "$json_data"
}

delete_container_registry() {
    registry=$(get_registry openclone)
    registry_id=$(echo "$registry" | jq -r '.id')
    
    response=$(delete_vultr "$registry_endpoint/$registry_id")
    if [ "$response" -eq 404 ]; then
        echo "No registry to delete (received 404)"
    elif [ "$response" -eq 204 ]; then
        echo "Registry deleted successfully"
    else
        echo "Unexpected response: $response"
    fi
}

get_registries() {
    get_vultr "$registries_endpoint"
}

get_registry() {
    registry_name=$1
    get_registries | jq --arg name "$registry_name" '.registries[] | select(.name == $name)'
}

################################################################################
######## REGISTRY PLANS ########################################################
################################################################################

list_registry_plans() {
    get_vultr "$registry_endpoint/plan/list"
}

filter_registry_plans() {
    local json_data=$1
    local min_storage_mb=${2:-0}
    local max_monthly_price=${3:-999999}

    echo "$json_data" | jq --argjson min_storage_mb "$min_storage_mb" \
        --argjson max_monthly_price "$max_monthly_price" \
        '.plans | to_entries |
        map(select(.value.max_storage_mb >= $min_storage_mb and .value.monthly_price <= $max_monthly_price)) |
        from_entries'
}

get_cheapest_registry_plan() {
    local min_storage_mb=${1:-0}
    local max_monthly_price=${2:-999999}

    # Retrieve plans
    json_data=$(list_registry_plans)

    # Get the filtered plans
    filtered_plans=$(filter_registry_plans "$json_data" "$min_storage_mb" "$max_monthly_price")

    # Find the plan with the lowest monthly_price and return its id
    echo "$filtered_plans" | jq -r 'to_entries | min_by(.value.monthly_price).key'
}

print_plan() {
    local plan_id=$1

    # Retrieve plans
    json_data=$(list_registry_plans)

    # Find and print the plan with the specified ID
    echo "$json_data" | jq --arg plan_id "$plan_id" '.plans[$plan_id]'
}

################################################################################
######## REPOSITORIES ##########################################################
################################################################################

get_repositories() {
    registry_json=$(get_registries)
    first_registry_id=$(echo "$registry_json" | jq -r '.registries[0].id')
    get_vultr "$registry_endpoint/$first_registry_id/repositories"
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi
