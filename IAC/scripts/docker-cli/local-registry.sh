#!/bin/bash

source /scripts/docker-cli/docker-network.sh

create_local_registry() {
    docker pull registry:2
    docker run -d -p $kind_registry_port:$kind_registry_port --name $kind_registry_name registry:2

    # Locate all images with "openclone" in the name and the tag "1.0"
    images=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -E '^openclone(-[a-zA-Z0-9-]+)?:1.0$')

    for image in $images; do
        # Retag and push each matching image to the local registry
        # Using the same name and tag, just prefixed with localhost:$kind_registry_port/
        new_image="localhost:$kind_registry_port/${image#*/}" # Strip any registry prefix if present

        # Optional: If we really needed to "delete" it first, we'd have to 
        # enable registry deletion and use registry APIs, which is non-trivial.
        # Here, we'll just push it again. This effectively updates it in the registry.
        
        echo "Pushing $new_image to the local registry..."
        docker tag "$image" "$new_image"
        docker push "$new_image"
    done
}

ensure_local_registry_is_running() {
    # Start the container

    remove_all_networks_from_container "$kind_registry_name" # this is important. docker network is needed because networking gets complicated when doing kind on a dev container and hosting the registry on the host... but when you restart your computer (or just rebuild the dev container?) the network gets deleted. BUT the registry container still thinks it's part of that deleted network and will no start until it sees that network. so remove that network from the registry container before trying to start it
    docker start "$kind_registry_name" >/dev/null 2>&1

    # Poll until the container is running and responding
    echo "Waiting for $kind_registry_name to be ready..."
    until docker inspect -f '{{.State.Running}}' "$kind_registry_name" 2>/dev/null | grep -q "true"; do
        sleep 1
    done

    echo "$kind_registry_name is running and reachable."
}

wait_till_registry_serving() {
    docker network connect bridge "$kind_registry_name" # bridge is the default docker network. add this container to bridge so we can get its ip address...
    ip_address=$(get_container_ip "$kind_registry_name" "$kind_network_name") # and use that to poll for the registry to be ready...
    ready_url="http://$ip_address:$kind_registry_port/v2/"
     # Wait for the registry to be ready
    echo "Checking if $kind_registry_name is serving requests on $ready_url..."
    until curl -fsSL "$ready_url" >/dev/null 2>&1; do
        echo "Waiting for $kind_registry_name to serve requests..."
        sleep 2
    done   
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi