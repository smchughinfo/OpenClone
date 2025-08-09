#!/bin/bash

source /vultr-api/api-base.sh

plan_endpoint="plans"

list_plans() {
    local all_plans="[]"
    local cursor=""
    local endpoint="$plan_endpoint"
    
    while true; do
        # Build the request URL with cursor if we have one
        if [ -n "$cursor" ]; then
            current_endpoint="${plan_endpoint}?cursor=${cursor}"
        else
            current_endpoint="$plan_endpoint"
        fi
        
        # Get the current page of plans
        response=$(get_vultr "$current_endpoint")
        if [ -z "$response" ]; then
            echo "Error: Failed to retrieve plans."
            return 1
        fi
        
        # Extract the plans from this page
        page_plans=$(echo "$response" | jq '.plans')
        if [ -z "$page_plans" ] || [ "$page_plans" = "null" ]; then
            echo "Error: No plans found in response."
            return 1
        fi
        
        # Merge this page's plans with our accumulated plans
        all_plans=$(echo "$all_plans $page_plans" | jq -s '.[0] + .[1]')
        
        # Check if there's a next page
        cursor=$(echo "$response" | jq -r '.meta.links.next // empty')
        if [ -z "$cursor" ]; then
            # No more pages, we're done
            break
        fi
    done
    
    # Return all plans in the same format as the original API
    echo "$all_plans" | jq '{"plans": .}'
}

get_plan() {
  local plan_id="$1"
  json_data=$(list_plans)

  # Extract the plan for the specified plan_id using jq
  local plan=$(echo "$json_data" | jq -r --arg plan_id "$plan_id" '.plans[] | select(.id == $plan_id)')
  
  # Output the plan
  echo "$plan"
}

get_plan_price() { # this function isn't being used. ordinarily i would delete it but i'm leaving it here for convenience
  local plan_id="$1"
  
  # Use get_plan to get the plan data
  local plan=$(get_plan "$plan_id")

  # Extract the price from the plan data
  local price=$(echo "$plan" | jq -r '.monthly_cost')
  
  # Output the price
  echo "$price"
}

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi