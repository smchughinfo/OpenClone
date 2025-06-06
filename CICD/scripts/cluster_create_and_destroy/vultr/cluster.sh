#!/bin/bash

source /vultr-api/clusters.sh
source /scripts/shell-helpers/aliases.sh

create_cluster() {
    echo "begin create vultr cluster..."
    create_kubernetes_cluster
    wait_for_kube_config
    wait_until_all_nodes_are_ready
}

destroy_cluster() {
    echo "Destroying Vultr cluster..."
    
    # Call delete_kubernetes_cluster and check its return value
    if ! delete_kubernetes_cluster; then
        echo "Failed to delete Vultr cluster."
        return 1
    fi
}

################################################################################
######## HELPERS ###############################################################
################################################################################

does_cluster_exist() {
    if get_cluster_vke_id >/dev/null 2>&1; then
        echo "true"
    else
        echo "false"
    fi
}

wait_for_kube_config() {
    echo "Waiting for kube config to be generated at: $TF_VAR_kube_config_path"
    while true; do
        echo "Attempting to save kube config..."
        save_kube_config

        if [ -f "$TF_VAR_kube_config_path" ] && grep -q 'kind: Config' "$TF_VAR_kube_config_path"; then # it takes a while after cluster creation for the api to return a kube-config file. until we get a kube-config the file just looks empty with a couple wrongly encoded charecters in it. as soon as we have any of the text that would actually be in the kube-config file (e.g. "Config") use that as the signal to know we got the kube-config file 
            echo "Kube config found at $TF_VAR_kube_config_path"
            break
        else
            echo "Kube config not ready yet, will try again in 15 seconds..."
        fi

        sleep 15
    done
    echo "Kube config is ready to use!"
}

wait_until_all_nodes_are_ready() {
    start_time=$(date +%s)
    echo "Waiting for all nodes to become ready..."

    while true; do
        status=$(k get nodes --no-headers 2>/dev/null)
        exit_code=$?

        current_time=$(date +%s)
        elapsed=$((current_time - start_time))
        minutes=$((elapsed / 60))
        seconds=$((elapsed % 60))

        if [ $exit_code -ne 0 ] || [ -z "$status" ]; then
            echo "Unable to connect to the Kubernetes API server. Elapsed Time: ${minutes}m ${seconds}s, will try again in 15 seconds..."
            sleep 15
            continue
        fi

        # Strip spaces from total_nodes
        total_nodes=$(echo "$status" | wc -l | xargs)
        
        # Initialize count to avoid empty values for ready_nodes
        ready_nodes=$(echo "$status" | awk 'BEGIN {count=0} $2 == "Ready" {count++} END {print count}')

        echo -ne "Total Nodes: ${total_nodes}, Ready Nodes: ${ready_nodes} | Elapsed Time: ${minutes}m ${seconds}s\r"

        if [ "$total_nodes" -ne 0 ] && [ "$total_nodes" -eq "$ready_nodes" ]; then
            echo -e "\nAll nodes are ready."
            break
        fi

        sleep 15
    done
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi
