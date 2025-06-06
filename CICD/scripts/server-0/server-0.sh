#!/bin/bash

source /scripts/docker-cli/push-containers.sh
source /vultr-api/instances.sh

server_0_delta_creds_path="/scripts/server-0/server-0-delta-creds"

create_cluster_with_server_0_delta() {
    # create server 0 delta
    result=$(create_instance_from_snapshot "$OpenClone_Server_0_Delta_Snapshot_ID")
    IFS="|" read -r instance_id default_password main_ip <<< "$result"
    echo "Server 0 Delta Instance ID: $instance_id"
    echo "Server 0 Delta Password: $default_password"
    echo "Server 0 Delta IP: $main_ip"
    
    # Write credentials to file
    cat > $server_0_delta_creds_path << EOF
$instance_id
$main_ip
$default_password
EOF
    
    # setup server 0 delta (the vps)
    upload_script $main_ip $default_password "$setup_server_0_path" "/setup_server_0.sh" true
    ## setup the server 0 delta container (this project, with all the kubernetes stuff, aka openclone-cicd)
    upload_script $main_ip $default_password "$setup_server_0_container_path" "/setup_server_0_container.sh" true
    ## print /setup_server_0_container.sh logs
    execute_server_0_command $main_ip $default_password "docker logs openclone-cicd-server-0"
    ## copy the start cluster script to the server 0 delta vps, which is what's used by the paywall website to start the cluster after the user pays.
    upload_script $main_ip $default_password "/scripts/server-0/start-cluster.sh" "/start-cluster.sh"
}
create_server_0_delta_terminal() {
    main_ip=$(sed -n '2p' $server_0_delta_creds_path)
    default_password=$(sed -n '3p' $server_0_delta_creds_path)
    
    execute_server_0_command $main_ip $default_password
}

create_server_0_delta_container_terminal() {
    main_ip=$(sed -n '2p' $server_0_delta_creds_path)
    default_password=$(sed -n '3p' $server_0_delta_creds_path)
    
    open_container_terminal $main_ip $default_password
}

get_kube_config() {
    main_ip=$(sed -n '2p' $server_0_delta_creds_path)
    default_password=$(sed -n '3p' $server_0_delta_creds_path)
    
    echo "Downloading kube config from Server-0-Delta container..."
    
    # Copy the kubeconfig file from the container to the host, then download it
    sshpass -p "$default_password" ssh -o StrictHostKeyChecking=no root@$main_ip "
        # Copy kubeconfig from container to host
        docker cp openclone-cicd-server-0:/terraform/vultr-dev-kube-config.yaml /tmp/vultr-dev-kube-config.yaml
        
        # Output the file content so we can capture it
        cat /tmp/vultr-dev-kube-config.yaml
    " > "$vultr_dev_kube_config_path"
    
    if [ $? -eq 0 ]; then
        echo "Download Complete!"
    else
        echo "Failed to download kube config"
        return 1
    fi
}

upload_script() {
    ip_address="$1"
    password="$2"
    local_path="$3"
    remote_path="$4"
    execute_script="${5:-false}"

    sshpass -p "$password" scp -o StrictHostKeyChecking=no "$local_path" "root@$ip_address:$remote_path"
    execute_server_0_command "$ip_address" "$password" "chmod +x $remote_path"
    if [ "$execute_script" == "true" ]; then
        execute_server_0_command "$ip_address" "$password" "bash $remote_path"
    fi
}

execute_server_0_command() {
    ip_address="$1"
    password="$2"
    command="$3"

    sshpass -p "$password" ssh -tt -o StrictHostKeyChecking=no "root@$ip_address" "$command"
}

open_container_terminal() {
    ip_address="$1"
    password="$2"
    execute_server_0_command "$ip_address" "$password"'
        CONTAINER_NAME="openclone-cicd-server-0"

        if docker ps -a --format "{{.Names}}\t{{.Status}}" | grep -q "$CONTAINER_NAME"; then
            if docker ps --format "{{.Names}}" | grep -q "$CONTAINER_NAME"; then
                echo "Container is running, attaching to it..."
            else
                echo "Container is stopped, starting it..."
                docker start "$CONTAINER_NAME"
                echo "Starting terminal in container..."
            fi
            docker exec -it "$CONTAINER_NAME" /bin/bash
        else
            echo "Container $CONTAINER_NAME not found!"
            exit 1
        fi
    '
}

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi