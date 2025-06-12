#!/bin/bash

source /vultr-api/api-base.sh

domain_endpoint="domains"

get_records() {
  echo $(get_vultr "$domain_endpoint/$TF_VAR_openclone_domain_name/records")
}


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

delete_record() {
  local record_name="$1"
  local records_response=$(get_records)
  
  # Extract record IDs that match the given name
  local record_ids=$(echo "$records_response" | jq -r ".records[] | select(.name == \"$record_name\") | .id")
  
  # Echo each matching record ID
  for id in $record_ids; do
    delete_vultr "$domain_endpoint/$TF_VAR_openclone_domain_name/records/$id"
  done
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