#!/bin/bash

source /vultr-api/api-base.sh
source /vultr-api/regions.sh

clusters_endpoint="kubernetes/clusters"

################################################################################
######## CLUSTER CRUD ##########################################################
################################################################################

list_kubernetes_clusters() {
    get_vultr "$clusters_endpoint"
}

create_kubernetes_cluster() {
    local cpu_node_plan=${1}
    local node_quantity=${2}
    local min_nodes=${3}
    local max_nodes=${4}
    local pool_label=${5}
    
    if [ -z "$cpu_node_plan" ] || [ -z "$node_quantity" ] || [ -z "$min_nodes" ] || [ -z "$max_nodes" ] || [ -z "$pool_label" ]; then
        echo "Error: Missing required parameters"
        echo "Usage: create_kubernetes_cluster <cpu_node_plan> <node_quantity> <min_nodes> <max_nodes> <pool_label>"
        return 1
    fi
    
    echo "Using CPU node plan: $cpu_node_plan"

    json_data=$(jo \
        label="$vultr_cluster_label"                    \
        region="$vultr_region"                          \
        version="$kubernetes_version"                   \
        node_pools=$(jo -a \
            $(jo                                        \
                node_quantity="$node_quantity"          \
                min_nodes="$min_nodes"                  \
                max_nodes="$max_nodes"                  \
                auto_scaler=true                        \
                label="$pool_label"                     \
                plan="$cpu_node_plan"                   \
            )                                           \
        )
    )

    echo -e "Creating cluster with CPU node pool only:\n$json_data"
    post_vultr "$clusters_endpoint" "$json_data"
    echo -e "\nCluster created!"
}

delete_kubernetes_cluster() {
    vke_id=$(get_cluster_vke_id) # Get the VKE ID
    echo "Destroying cluster $vke_id"
    result=$(delete_vultr "$clusters_endpoint/$vke_id")

    if [ "$result" != "204" ]; then
        echo "Error: Cluster deletion failed. Response code: $result"
        return 1
    fi

    echo "Vultr cluster destroyed! Make sure to check https://my.vultr.com/ for any resources that might have been missed."
}

get_cluster_vke_id() {
    cluster_id=$(list_kubernetes_clusters | jq -r '.vke_clusters[0].id')
    if [[ -z "$cluster_id" || "$cluster_id" == "null" ]]; then
        return 1  # Return non-zero to indicate failure
    fi
    echo "$cluster_id"
    return 0
}

################################################################################
######## NODE POOL CRUD ########################################################
################################################################################

create_node_pool() {
    local node_plan=${1}
    local pool_label=${2}
    local max_nodes=${3}
    
    if [ -z "$node_plan" ] || [ -z "$pool_label" ] || [ -z "$max_nodes" ]; then
        echo "Error: Missing required parameters"
        echo "Usage: create_node_pool <node_plan> <pool_label> <max_nodes>"
        return 1
    fi
    
    vke_id=$(get_cluster_vke_id)
    if [ $? -ne 0 ]; then
        echo "Error: Could not get cluster ID"
        return 1
    fi
    
    echo "Creating node pool with plan: $node_plan, label: $pool_label, max_nodes: $max_nodes"
    
    # Determine node configuration based on pool label
    if [[ "$pool_label" == *"gpu"* ]]; then
        node_quantity="$vultr_gpu_node_quantity"
        min_nodes="$vultr_gpu_min_nodes"
    else
        node_quantity="$vultr_cpu_node_quantity"
        min_nodes="$vultr_cpu_min_nodes"
    fi
    
    json_data=$(jo \
        node_quantity="$node_quantity" \
        min_nodes="$min_nodes" \
        max_nodes="$max_nodes" \
        auto_scaler=true \
        label="$pool_label" \
        plan="$node_plan" \
    )
    
    echo -e "Creating node pool:\n$json_data"
    result=$(post_vultr "$clusters_endpoint/$vke_id/node-pools" "$json_data")
    
    if echo "$result" | jq -e '.node_pool.id' > /dev/null 2>&1; then
        pool_id=$(echo "$result" | jq -r '.node_pool.id')
        echo "Node pool created successfully! ID: $pool_id"
        return 0
    else
        echo "Error: Node pool creation failed"
        echo "$result"
        return 1
    fi
}

delete_node_pool() {
    local pool_id=${1}
    
    if [ -z "$pool_id" ]; then
        echo "Error: Node pool ID required"
        echo "Usage: delete_node_pool <pool_id>"
        return 1
    fi
    
    vke_id=$(get_cluster_vke_id)
    if [ $? -ne 0 ]; then
        echo "Error: Could not get cluster ID"
        return 1
    fi
    
    echo "Deleting node pool $pool_id from cluster $vke_id"
    result=$(delete_vultr "$clusters_endpoint/$vke_id/node-pools/$pool_id")
    
    if [ "$result" = "204" ]; then
        echo "Node pool deleted successfully!"
        return 0
    else
        echo "Error: Node pool deletion failed. Response code: $result"
        return 1
    fi
}

list_node_pools() {
    vke_id=$(get_cluster_vke_id)
    if [ $? -ne 0 ]; then
        echo "Error: Could not get cluster ID"
        return 1
    fi
    
    echo "Listing node pools for cluster $vke_id"
    get_vultr "$clusters_endpoint/$vke_id/node-pools"
}

################################################################################
######## UTILITY FUNCTIONS #####################################################
################################################################################

save_kube_config() {
    vke_id=$(get_cluster_vke_id) # Get the VKE ID
    kube_config_wrapper=$(get_vultr "$clusters_endpoint/$vke_id/config") # Fetch the kubeconfig
    kube_config_base64=$(echo "$kube_config_wrapper" | jq -r '.kube_config')
    echo "$kube_config_base64" | base64 --decode > "$TF_VAR_kube_config_path"
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi
