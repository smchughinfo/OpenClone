#!/bin/bash

source /vultr-api/api-base.sh

domain_endpoint="domains"

delete_domain() {
  local domain="$1"
  delete_vultr "$domain_endpoint/$domain"
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi