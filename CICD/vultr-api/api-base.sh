#!/bin/bash

get_vultr() {
    local endpoint=$1
    local endpoint_args=$2

    curl -s "https://api.vultr.com/v2/$endpoint" \
    -H "Authorization: Bearer $TF_VAR_vultr_api_key" \
    $endpoint_args
}

post_vultr() {
    local endpoint=$1
    local endpoint_args=$2

    curl -s "https://api.vultr.com/v2/$endpoint" \
    -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TF_VAR_vultr_api_key" \
    -d "$endpoint_args"
}

delete_vultr() {
    local endpoint=$1
    local endpoint_args=$2

    curl -s -o /dev/null -w "%{http_code}" "https://api.vultr.com/v2/$endpoint" \
    -X DELETE \
    -H "Authorization: Bearer $TF_VAR_vultr_api_key" \
    $endpoint_args
}
