#!/bin/bash

source /scripts/docker-cli/login.sh
source /vultr-api/registries.sh

list_container_images() {
    echo "getting please wait..."
    repositories_json=$(get_repositories)

    # Loop through each repository and print its name, trimming "openclone/" from the start
    echo "$repositories_json" | jq -r '.repositories[].name' | while read -r repository_name; do
        trimmed_name=$(echo "$repository_name" | sed 's|^openclone/||')
        get_current_remote_image_name $trimmed_name
    done
}


get_current_version_tag() { # this will return 0 if nothing is found.
    container_name="$1"
    i=1

    login_to_container_registry
    while true; do
        current_tag="$i.0"

        # Use docker manifest inspect to check for the tag's existence
        if ! docker manifest inspect "$(get_remote_registry_name)/$container_name:$current_tag" >/dev/null 2>&1; then
            # Return the previous tag, as it's the current version
            previous_tag="$(($i - 1)).0"
            echo "$previous_tag"
            break
        fi

        # Increment to check the next version
        i=$(($i + 1))
    done
}

get_next_version_tag() {
    container_name="$1"
    # Get the current version tag and add 1 to it
    current_tag=$(get_current_version_tag "$container_name" | tail -n1)
    next_major_version=$((${current_tag%%.*} + 1))
    next_tag="${next_major_version}.0"
    echo "$next_tag"
}

get_remote_registry_name() {
    echo "$vultr_region.vultrcr.com/openclone"
}

get_current_remote_image_name() { # this will return a tag with 0 as the version if nothing is found.
    container_name="$1"
    tag=$(get_current_version_tag "$container_name" | tail -n1)
    echo "$(get_remote_registry_name)/$container_name:$tag"
}

get_next_remote_image_name() {
    container_name="$1"
    tag=$(get_next_version_tag $container_name)
    echo "$(get_remote_registry_name)/$container_name:$tag"
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi