terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.15.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
  }
}

#######################################################################
###### VULTR ##########################################################
#######################################################################

provider "vultr" {
  api_key = var.vultr_api_key
}

#######################################################################
###### KUBERNETES #####################################################
#######################################################################

provider "kubernetes" {
  config_path = var.kube_config_path
  insecure    = var.environment == "kind" ? true : false
}
