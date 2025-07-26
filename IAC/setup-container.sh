#!/bin/bash

source /scripts/shell-helpers/utility-functions.sh
source /scripts/environment.sh

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

    set_env_variable vultr_dev_kube_config_path "/terraform/vultr-dev-kube-config.yaml"
    switch_environment $(get_terraform_environment) 
    set_env_variable kubernetes_version "v1.33.0+1" # this is the remote version. make sure it matches the kubectl you install in your dockerfile

    ################################################################################
    ######## VULTR KUBERNETES CONFIGURATIONS #######################################
    ################################################################################

    set_env_variable vultr_region "ewr"
    set_env_variable vultr_cluster_label "openclone-cluster"
    set_env_variable vultr_cpu_node_pool_label "cpu-node-pool"
    set_env_variable vultr_gpu_node_pool_label "gpu-node-pool"
    
    # Set Terraform variables for node pool labels
    set_env_variable TF_VAR_vultr_cpu_node_pool_label "cpu-node-pool"
    set_env_variable TF_VAR_vultr_gpu_node_pool_label "gpu-node-pool"

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
}
setup_container
echo "setup-container.sh complete!" # inform the user of our success.