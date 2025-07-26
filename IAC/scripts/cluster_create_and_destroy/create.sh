#!/bin/bash

source /scripts/shell-helpers/utility-functions.sh
source /scripts/environment.sh
source /scripts/docker-cli/tag-resolver.sh
source /scripts/openclone-fs/longhorn/longhorn.sh
source /vultr-api/domains.sh

################################################################################
######## MAIN LOGIC ############################################################
################################################################################

create() {
  set_terraform_workspace $TF_VAR_environment #todo: seems superflous but this is for server-0-delta. see if you can get rid of it (may not be easy)
  source_environment_logic

  if [ "$(does_cluster_exist)" == "false" ]; then
    ensure_success create_cluster_in_environment
  fi
  
  terraform -chdir="/terraform" init
  install_longhorn
  terraform -chdir="/terraform" apply -auto-approve \
    -var="dns_already_created=$(domain_exists $TF_VAR_openclone_domain_name)" \
    -var="image_name_openclone_sadtalker=$(get_current_remote_image_name openclone-sadtalker)" \
    -var="image_name_openclone_u-2-net=$(get_current_remote_image_name openclone-u-2-net)" \
    -var="image_name_openclone_database=$(get_current_remote_image_name openclone-database)" \
    -var="image_name_openclone_website=$(get_current_remote_image_name openclone-website)"
}

################################################################################
######## HELPERS ###############################################################
################################################################################

source_environment_logic() {
  source /scripts/cluster_create_and_destroy/vultr/cluster.sh
}

create_cluster_in_environment() {
  create_cluster

  if [ "$(does_cluster_exist)" == "true" ]; then
      echo "cluster $cluster_name created!"
      return 0
  else
      echo "error creating cluster $cluster_name"
      return 1
  fi
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi
