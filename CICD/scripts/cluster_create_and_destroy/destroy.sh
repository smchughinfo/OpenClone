#!/bin/bash

source /scripts/shell-helpers/utility-functions.sh
source /scripts/environment.sh
source /scripts/docker-cli/tag-resolver.sh
source /vultr-api/load-balancers.sh
source /vultr-api/vpcs.sh
source /vultr-api/domains.sh

################################################################################
######## MAIN LOGIC ############################################################
################################################################################

destroy() {
  source_environment_logic
  # actually this steps slows down deletion dramatically in some cases (for example can't get image name from registry) --- run_terraform_destroy # i think this step is actually not necessary as everything it does gets covered by destroying the cluster and the workspace. but here it is anyways, just in case... oh, and if it fails oh well, just continue executing the rest of the destroy script.
  ensure_success destroy_cluster_in_environment
  cleanup_cluster

  # these ones don't get handled by terraform for some reason so do them manually
  delete_all_loadbalancers
  delete_all_vpcs

  # inform user of the situation...
  print_cluster_destroy_message
}

run_terraform_destroy() { # this function is not actually used by any of the automations. but it is the "right way" to do the destroy
    terraform -chdir="/terraform" destroy -auto-approve \
    -var="image_name_openclone_sadtalker=$(get_current_remote_image_name openclone-sadtalker)" \
    -var="image_name_openclone_u-2-net=$(get_current_remote_image_name openclone-u-2-net)" \
    -var="image_name_openclone_database=$(get_current_remote_image_name openclone-database)" \
    -var="image_name_openclone_website=$(get_current_remote_image_name openclone)"
}

################################################################################
######## HELPERS ###############################################################
################################################################################

source_environment_logic() {
  if [[ "$TF_VAR_kube_config_path" == "$kind_kube_config_path" ]]; then
    source /scripts/cluster_create_and_destroy/kind/cluster.sh    
  elif [[ "$TF_VAR_kube_config_path" == "$vultr_dev_kube_config_path" ]]; then
    source /scripts/cluster_create_and_destroy/vultr/cluster.sh
  fi
}

destroy_cluster_in_environment() {
    # Initialize variables
    local kube_config_exists=false
    local destroy_returned_nonzero=false
    local cluster_exists_after_destroy=false

    # 1. Check if kube config file exists
    if [[ -f "$TF_VAR_kube_config_path" ]]; then
        kube_config_exists=true
    fi

    # 2. Try to destroy the cluster 
    if ! destroy_cluster; then
        destroy_returned_nonzero=true
    fi

    # 3. Check if cluster still exists after attempting destroy
    if [[ "$(does_cluster_exist)" == "true" ]]; then
        cluster_exists_after_destroy=true
    fi

    # Evaluate conditions
    if [[ $kube_config_exists == false || $destroy_returned_nonzero == true || $cluster_exists_after_destroy == true ]]; then
        echo "Failed to delete cluster!"
        if prompt_force_delete; then
            return 0
        else
            return 1
        fi
    fi
}


prompt_force_delete() {
  read -p "Press y to force delete cluster files anyways, or any other key to exit: " choice
  if [ "$choice" != "y" ]; then
      return 1
  else
      echo "Forcing terraform file deletion."
      return 0
  fi
}

cleanup_cluster() {
  echo "begin cluster cleanup..."
  terraform -chdir="/terraform" workspace select default
  terraform -chdir="/terraform" workspace delete -force $TF_VAR_environment
  remove_if_exists $TF_VAR_kube_config_path
}

print_cluster_destroy_message() {
  # Define color codes
  YELLOW="\033[1;33m"
  CYAN="\033[1;36m"
  GREEN="\033[1;32m"
  DEFAULT="\033[0m"
  
  # Print the message with appropriate colors and indentations
  echo -e "${YELLOW}Cluster destroy operation has completed. However, at this point the cluster may be in one of three states:${DEFAULT}\n"
  echo -e "  ${DEFAULT}1. It never existed and this destroy operation did nothing."
  echo -e "  ${DEFAULT}2. It did exist or partially existed and this destroy operation destroyed it."
  echo -e "  ${DEFAULT}3. It did exist or partially existed but there was an error during the destroy process and the cluster still exists. In this case cluster files may or may not have been deleted depending on whether or not you chose to force delete them.\n"
  echo -e "${CYAN}Capturing every state and error condition would make the code a lot more complicated. So the destroy operation runs all delete code any time you call it and doesn't have a bunch of logic to handle the many types of states and fail conditions that could occur.${DEFAULT}\n"
  echo -e "${GREEN}The cluster should be destroyed but please verify if you are in doubt.${DEFAULT}"
}

################################################################################
######## EXPOSE SCRIPT TO COMMAND LINE #########################################
################################################################################

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi
