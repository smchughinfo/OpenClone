#!/bin/bash

source /scripts/shell-helpers/utility-functions.sh
source /scripts/environment.sh
source /scripts/cluster_create_and_destroy/kind/cluster.sh

setup_container() {
    ################################################################################
    ######## CONTAINER PATHS #######################################################
    ################################################################################

    chmod -R 777 /scripts /terraform /vultr-api

    ################################################################################
    ######## APP CONFIGURATIONS ####################################################
    ################################################################################

    set_env_variable TF_VAR_openclone_domain_name "clonezone.me"
    set_env_variable TF_VAR_openclone_jwt_issuer "https://www.clonezone.me"
    set_env_variable TF_VAR_openclone_jwt_audience "clonezone-prod"
    set_env_variable TF_VAR_openclone_opencloneloglevel "Information"
    set_env_variable TF_VAR_openclone_systemloglevel "Error"
    # probably can delete -> set_env_variable TF_VAR_OpenClone_OpenCloneFS "/OpenCloneFS"

    set_env_variable TF_VAR_openclone_sadtalker_port 5001
    set_env_variable TF_VAR_openclone_sadtalker_hostaddress "http://openclone-sadtalker-clusterip:$TF_VAR_openclone_sadtalker_port"

    set_env_variable TF_VAR_openclone_u2net_port 5002
    set_env_variable TF_VAR_openclone_u2net_hostaddress "http://openclone-u-2-net-clusterip:$TF_VAR_openclone_u2net_port"

    ################################################################################
    ######## ALIASES ###############################################################
    ################################################################################
    
    echo 'source /scripts/shell-helpers/aliases.sh' >> ~/.bashrc

    ################################################################################
    ######## ENVIRONMENT ################################################
    ################################################################################

    set_env_variable kind_kube_config_path "/terraform/kind-kube-config.yaml"
    set_env_variable vultr_dev_kube_config_path "/terraform/vultr-dev-kube-config.yaml"
    switch_environment $(get_terraform_environment) 
    set_env_variable kubernetes_version "v1.33.0+1" # this is the remote version. make sure it matches the kubectl you install in your dockerfile

    ################################################################################
    ######## VULTR KUBERNETES CONFIGURATIONS #######################################
    ################################################################################

    set_env_variable vultr_region "ewr"
    set_env_variable vultr_cluster_label "openclone-cluster"
    set_env_variable vultr_all_deployments_node_pool_label "all-deployments-node-pool"

    ################################################################################
    ######## CONNECTION STRINGS ####################################################
    ################################################################################

    # internal means within the cluster
    set_env_variable TF_VAR_internal_openclone_defaultconnection "Host=openclone-database-clusterip;Port=5432;Database=$TF_VAR_openclone_openclonedb_name;Username=$TF_VAR_openclone_openclonedb_user;Password=$TF_VAR_openclone_openclonedb_password;Include Error Detail=true;"
    set_env_variable TF_VAR_internal_openclone_logdbconnection "Host=openclone-database-clusterip;Port=5432;Database=$TF_VAR_openclone_logdb_name;Username=$TF_VAR_openclone_logdb_user;Password=$TF_VAR_openclone_logdb_password;"

    ################################################################################
    ######## NODE PORTS ############################################################
    ################################################################################

    set_env_variable TF_VAR_sftp_nodeport 30222
    set_env_variable TF_VAR_database_nodeport 30223
    set_env_variable TF_VAR_website_nodeport 30224

    ################################################################################
    ######## KIND ##################################################################
    ################################################################################

    set_env_variable cluster_name openclone-kind-cluster
    set_env_variable cluster_control_plane_container_name openclone-kind-cluster-control-plane
    set_env_variable kind_network_name kind-network

    set_env_variable kind_registry_name kind-registry
    set_env_variable kind_registry_host kind-registry.local
    set_env_variable kind_registry_hostname "kind-registry.local"
    set_env_variable kind_registry_port 5000

    set_env_variable kind_config_path "/scripts/cluster_create_and_destroy/kind/config/kind-config.yaml"
    kind_config_path_template="/scripts/cluster_create_and_destroy/kind/config/kind-config-template.yaml"
    envsubst < $kind_config_path_template > $kind_config_path
    if [[ -f "$kind_kube_config_path" ]]; then
        setup_kind_network
    fi

    vultr_csi_secret_path_template="/scripts/cluster_create_and_destroy/kind/config/vultr-csi-secret-template.yaml"
    set_env_variable vultr_csi_secret_path "/scripts/cluster_create_and_destroy/kind/config/vultr-csi-secret.yaml"
    envsubst < "$vultr_csi_secret_path_template" > "$vultr_csi_secret_path"

    ################################################################################
    ######## SERVER-0 ##############################################################
    ################################################################################

    # todo: these files should be server-0-delta, not server-0
    setup_server_0_path_template="/scripts/server-0/setup-server-0-template.sh"
    set_env_variable setup_server_0_path "/scripts/server-0/setup-server-0.sh"
    envsubst '$OpenClone_Server_0_Cluster_Password' < "$setup_server_0_path_template" > "$setup_server_0_path"

    # todo: these files should be server-0-delta, not server-0
    setup_server_0_container_path_template="/scripts/server-0/setup-server-0-container-template.sh"
    set_env_variable setup_server_0_container_path "/scripts/server-0/setup-server-0-container.sh"
    envsubst '$TF_VAR_postgres_password,$TF_VAR_openclone_openclonedb_password,$TF_VAR_openclone_logdb_password,$TF_VAR_vultr_api_key,$TF_VAR_openclone_jwt_secretkey,$TF_VAR_openclone_openai_api_key,$TF_VAR_openclone_googleclientid,$TF_VAR_openclone_googleclientsecret,$TF_VAR_openclone_elevenlabsapikey,$TF_VAR_openclone_email_dkim,$Server_0_CICD_ENV,$OpenClone_Root_Dir,$OpenClone_OpenCloneFS,$CLUSTER_PASSWORD,$OpenClone_Server_0_vultr_dev_kube_config_path,$OpenClone_Resistry_User,$OpenClone_Registry_Password,$Server_0_CICD_ENV,$OpenClone_Server_0_OpenClone_Root_Dir,$OpenClone_Server_0_OpenClone_OpenCloneFS' < "$setup_server_0_container_path_template" > "$setup_server_0_container_path"
}
setup_container
echo "setup-container.sh complete!" # inform the user of our success.