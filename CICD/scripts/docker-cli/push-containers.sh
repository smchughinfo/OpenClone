#!/bin/bash

source /scripts/docker-cli/login.sh
source /scripts/docker-cli/tag-resolver.sh
source /vultr-api/registries.sh
source /scripts/devcontainer-host/host-commands.sh

# Get last updated date of the container images
get_last_updated_date() {
    local image_name="$1"
    local created_date
    created_date=$(docker inspect --format='{{.Created}}' "$image_name" 2>/dev/null)
    
    if [ -z "$created_date" ]; then
        echo "Image not found locally."
    else
        # Convert the timestamp to mm/dd/yyyy hh:mm am/pm format
        date -d "$created_date" +"%m/%d/%Y %I:%M %p"
    fi
}

push_container() {
    local image_name="$1"
    echo "Starting container push for: $image_name"

    login_to_container_registry

    # always use these values
    build_path="$(get_container_build_path ${image_name})"
    remote_name="$(get_next_remote_image_name ${image_name})"
    local_name=""
    dockerfile=""

    echo "remote name: $remote_name"

    if [[ "$image_name" == "openclone-cicd" ]]; then
        local_name="${image_name}:1.0"
        dockerfile="Dockerfile_ForDeployment"
        echo "deleting /terraform/.terraform for clean image creation"
        rm -r /terraform/.terraform
    else
        local_name="${image_name}:1.0"
        dockerfile="Dockerfile"
    fi

    echo "Building image: $local_name"
    run_host_command "cd \"$build_path\" && docker build --no-cache -f $dockerfile -t $local_name ."
    
    echo "Tagging as: $remote_name"
    docker tag $local_name $remote_name
    
    echo "Pushing to registry: $remote_name"
    docker push $remote_name
    
    echo "Container push completed for: $image_name"
}

get_container_build_path() {
    local image_name="$1"
    
    case "$image_name" in
        "openclone-u-2-net")
            echo "$OpenClone_Root_Dir/U-2-Net"
            ;;
        "openclone-sadtalker")
            echo "$OpenClone_Root_Dir/SadTalker"
            ;;
        "openclone-database")
            echo "$OpenClone_Root_Dir/Database"
            ;;
        "openclone-cicd")
            echo "$OpenClone_Root_Dir/CICD"
            ;;
        "openclone-website")
            echo "$OpenClone_Root_Dir/Website"
            ;;
        *)
            echo "$OpenClone_Root_Dir"
            ;;
    esac
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi