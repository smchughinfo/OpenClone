#!/bin/bash

source /scripts/shell-helpers/aliases.sh
source /vultr-api/domains.sh

install_longhorn() {
    # https://docs.vultr.com/how-to-install-longhorn-on-kubernetes

    # Dont reinstall if its already installed
    longhorn_already_installed=$(k get all -n longhorn-system --no-headers 2>/dev/null | wc -l)
    if [ "$longhorn_already_installed" -gt 0 ]; then
        echo "Longhorn already installed!"
        return
    fi

    # Install Longhorn
    echo "Installing Longhorn..."
    longhorn_path="/scripts/openclone-fs/longhorn/longhorn.yaml"
    curl -fsSL -o $longhorn_path https://github.com/longhorn/longhorn/releases/download/v1.7.2/longhorn.yaml
    #sed -i 's|$ext4_true_dir/|/mnt/longhorn/|g' $longhorn_path
    k apply -f $longhorn_path


    # Install the latest Longhorn NFS package to enable the creation of ReadWriteMany (RWX) volumes in your cluster.
    longhorn_nfs_path=https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/deploy/prerequisite/longhorn-nfs-installation.yaml
    if [[ "$TF_VAR_kube_config_path" == "$kind_kube_config_path" ]]; then
        # Use a custom YAML file for kind because the default NFS installation YAML
        # is designed for non-containerized nodes and needs adjustments (e.g., compatible base image)
        # to work properly in kind's containerized environment.
        longhorn_nfs_path="/scripts/openclone-fs/longhorn/longhorn-nfs-installation.yaml"
    fi
    k apply -f $longhorn_nfs_path
}

get_longhorn_loadbalancer() {
    k get services ingress-nginx-controller --namespace=ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
}

configure_longhorn_for_external_access() {
    # return if longhorn is already configured for external access
    if [ "$(get_longhorn_loadbalancer)" != "" ]; then # todo: this check needs to be improved. if creating the A record fails it will exit here instead of retying to create the A record.
        echo "Longhorn is already configured for external access!"
        return
    fi

    echo "Configuring longhorn for external access..."
    k apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml

    while [[ $(get_longhorn_loadbalancer) == "" ]]; do
        echo "Waiting for external IP..."
        sleep 5
    done

    echo "Begin 3 minute safety sleep before creating A record (if it errors, wait a few minutes and try again)"
    sleep 180 # todo: this should be replaced by checking whether the A record was successfully created

    # Capture the external IP after it's available
    public_ip=$(get_longhorn_loadbalancer)

    # Create A record pointing longhorn subdomain to the public IP
    echo "Longhorn Public IP: $public_ip"
    add_record "longhorn" "A" "$public_ip"

    # Create the longhorn ingress
    longhorn_ingress_template_path="/scripts/openclone-fs/longhorn/longhorn-ingress-template.yaml"
    longhorn_ingress_path="/scripts/openclone-fs/longhorn/longhorn-ingress.yaml"
    envsubst < $longhorn_ingress_template_path > $longhorn_ingress_path
    k apply -f $longhorn_ingress_path
    rm "$longhorn_ingress_path"
}

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi