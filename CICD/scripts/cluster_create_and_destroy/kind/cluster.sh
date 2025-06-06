#!/bin/bash

source /scripts/docker-cli/docker-network.sh
source /scripts/docker-cli/local-registry.sh
source /scripts/shell-helpers/aliases.sh

################################################################################
######## MAIN LOGIC ############################################################
################################################################################

create_cluster() {
    echo "begin create kind cluster..."

    if kind get clusters | grep -q "^${cluster_name}$"; then
        echo "Cluster '${cluster_name}' already exists. Skipping creation."
    else
        export KUBECONFIG="$kind_kube_config_path"
        echo "Cluster '${cluster_name}' does not exist. Creating it now."
        kubernetes_version_without_the_plus=$(echo "$kubernetes_version" | cut -d'+' -f1)
        kind create cluster --name "${cluster_name}" --config "${kind_config_path}" --image "kindest/node:$kubernetes_version_without_the_plus"
    fi

    # note - if you change anything below this line you may need to destory and recreate the kind environment
    setup_kind_network
    wait_till_cluster_ready
    setup_shared_storage
}

install_vultr_csi() {
    k create -f $vultr_csi_secret_path
    k apply -f https://raw.githubusercontent.com/vultr/vultr-csi/master/docs/releases/latest.yml
}

destroy_cluster() {
    echo "destroying cluster: $cluster_name"
    delete_container_network "$kind_network_name"
    kind delete cluster --name "$cluster_name"
}

################################################################################
######## HELPERS ###############################################################
################################################################################

setup_kind_network() {
    # create the network and add the dev container
    create_container_network "$kind_network_name" "$HOSTNAME"

    # kind registry
    ensure_local_registry_is_running
    put_container_on_network "$kind_network_name" "$kind_registry_name"
    wait_till_registry_serving "$kind_registry_name"

    # control plane
    put_container_on_network "$kind_network_name" "$cluster_control_plane_container_name"
    resolve_cluster_api_through_hosts_file

    # registry
    give_container_dns_hostname "$kind_registry_name" "$kind_registry_host" "$kind_network_name"
}

#   - Enables Grafana to run smoothly by ensuring Helm can communicate with the Kubernetes API server.
#   - Helm requires a valid TLS certificate to interact with the cluster.
#   - Instead of creating a new certificate, we utilize the default API server certificate which includes 'DNS:kubernetes'.
#   - This is achieved by mapping the API server's IP address to the hostname 'kubernetes' in the /etc/hosts file.
#   - This workaround prevents TLS verification errors without the need to manage custom certificates.
resolve_cluster_api_through_hosts_file() {
    local kubeconfig_path="$TF_VAR_kube_config_path"
    local control_plane_ip
    control_plane_ip=$(get_container_ip "$cluster_control_plane_container_name" "$kind_network_name")

    # 1. Update /etc/hosts without using sed -i
    sed '/\s*kubernetes$/d' /etc/hosts > /tmp/hosts_temp
    echo "$control_plane_ip kubernetes" >> /tmp/hosts_temp
    cp /tmp/hosts_temp /etc/hosts
    rm /tmp/hosts_temp
    echo "Updated /etc/hosts with '$control_plane_ip kubernetes'"

    # 2. Update 'server:' in the kubeconfig
    #    Make sure you have the Go-based mikefarah/yq installed
    yq eval --inplace "
      (.clusters[] | select(.name == \"kind-openclone-kind-cluster\").cluster.server) = \"https://kubernetes:6443\"
    " "$kubeconfig_path"

    echo "Updated kubeconfig '$kubeconfig_path' server to 'https://kubernetes:6443'"
}

does_cluster_exist() {
    kind get clusters | grep -q "^$cluster_name$"
    if [ $? -eq 0 ]; then
        echo "true"
    else
        echo "false"
    fi
}

wait_till_cluster_ready() {
    echo "Waiting for cluster nodes to be Ready..."
    while ! k get nodes 2>/dev/null | grep -q "Ready"; do
        sleep 2
        echo "Still waiting for nodes to become Ready..."
    done
}

setup_shared_storage() {
    # you can't have multiple pods reading from the same pvc at the same time
    # you can't create a consistent setup locally on windows and in the remote cluster
    # because ALL the softwares have one problem or another. so instead just create
    # docker shared storage locally and handle remote in a different way
  
    # Create shared directory on the Kind control plane node
    docker exec $cluster_control_plane_container_name mkdir -p /shared-data
    docker exec $cluster_control_plane_container_name chmod 777 /shared-data
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi