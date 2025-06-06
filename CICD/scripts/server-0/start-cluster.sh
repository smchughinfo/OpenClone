#!/bin/bash

CONTAINER_NAME="openclone-cicd"

start_cluster() {
   # Set PS1 to bypass .bashrc's non-interactive guard that prevents environment variables from loading.
   # Without this, .bashrc exits early and our export statements at the bottom never execute.
   docker exec -it $CONTAINER_NAME /bin/bash -c "
       export PS1='$ ' &&
       source ~/.bashrc &&
       echo 'Variables loaded Test --- TF_VAR_environment:' \$TF_VAR_environment 'TF_VAR_kube_config_path:' \$TF_VAR_kube_config_path && 
       /scripts/cluster_create_and_destroy/create.sh --create && 
       /bin/bash"
}

wait_for_container() {
    local container_name=$1
    
    echo "Waiting for container to be ready..."
    while ! docker exec $container_name echo "Container ready" >/dev/null 2>&1; do
        echo "Container not ready yet, waiting..."
        sleep 5
    done
    echo "Container is ready!"
}

start_container() {
    if docker ps --filter "name=^${CONTAINER_NAME}$" --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container is already running. Running create.sh and attaching..."
    else
        echo "Starting container, running create.sh and attaching..."
        docker start $CONTAINER_NAME
        wait_for_container $CONTAINER_NAME
    fi
}

start_container
start_cluster
