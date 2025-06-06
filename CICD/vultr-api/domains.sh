#!/bin/bash

source /vultr-api/api-base.sh

domain_endpoint="domains"

add_record() {
  local name="$1"
  local type="$2"
  local data="$3"

  json_data=$(jo \
      name="$name"          \
      type="$type"          \
      data="$data"          \
  )

  echo -e "\nAttempting to create DNS Record:\n$json_data\n"
  post_vultr "$domain_endpoint/$TF_VAR_openclone_domain_name/records" "$json_data"
}

domain_exists() {
  local domain="$1"
  local response=$(get_vultr "$domain_endpoint/$domain")
  
  if echo "$response" | jq -e '.domain' > /dev/null 2>&1; then
    echo "true"
    return 0
  else
    echo "false"
    return 1
  fi
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi