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
    all_deployments_node_plan=$(get_cheapest_cpu_node_plan)
    echo "Using node plan: $all_deployments_node_plan"

    json_data=$(jo \
        label="$vultr_cluster_label"                    \
        region="$vultr_region"                          \
        version="$kubernetes_version"                   \
        node_pools=$(jo -a $(jo                         \
            node_quantity=1                             \
            min_nodes=1                                 \
            max_nodes=4                                 \
            auto_scaler=true                            \
            label="$vultr_all_deployments_node_pool_label"     \
            plan="$all_deployments_node_plan"
        ))
    )

    echo -e "Creating cluster:\n$json_data"
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
