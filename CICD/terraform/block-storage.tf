resource "kubernetes_storage_class" "longhorn_rwx" {
  metadata {
    name = "longhorn-rwx"
  }

  storage_provisioner    = "driver.longhorn.io"
  reclaim_policy        = "Retain"  # Note: corrected from your YAML which had conflicting policies
  volume_binding_mode   = "Immediate"
  allow_volume_expansion = true

  parameters = {
    numberOfReplicas      = "3"
    staleReplicaTimeout  = "2880"
    fromBackup           = ""
    fsType               = "ext4"
    nfsOptions           = "vers=4.2,noresvport,softerr,timeo=600,retrans=5,rw,hard"
  }
}

resource "kubernetes_persistent_volume_claim" "openclone_fs_pvc" {
  metadata {
    name = "openclone-fs-pvc"
  }
  
  wait_until_bound = false
  
  spec {
    access_modes = ["ReadWriteMany"]  # Changed to ReadWriteMany for shared access
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = (var.environment == "vultr_dev" || var.environment == "vultr_prod") ?  "longhorn-rwx" :  kubernetes_storage_class.manual_hostpath.metadata[0].name
  }
}

# because this takes so long i would prefer to do it manually....
######resource "null_resource" "init_fs" {
######  provisioner "local-exec" {
######    command = "/scripts/openclone-fs/openclone-fs.sh --push_openclone_fs"
######  }
######}
################################################################################
######## FTP ###################################################################
################################################################################

resource "kubernetes_deployment" "openclone_sftp" {
  depends_on = [ kubernetes_persistent_volume_claim.openclone_fs_pvc ]
  metadata {
    name = "openclone-sftp-deployment"
  }
  spec {
    replicas = 1
    selector { match_labels = { pod_id = "openclone-sftp-pod" } }
    template {
      metadata { labels = { pod_id = "openclone-sftp-pod" } }
      spec {
        
        # Init container to set ownership
        init_container {
          name  = "init-permissions"
          image = "busybox"
          command = ["sh", "-c", "chown -R 1001:1001 /home/openclone-ftp/OpenCloneFS"]
          volume_mount {
            name       = "openclone-fs"
            mount_path = "/home/openclone-ftp/OpenCloneFS"
          }
        }
        container {
          name  = "openclone-sftp"
          image = "atmoz/sftp"
          args = [var.TF_VAR_OpenClone_FTP_User+":"+var.TF_VAR_OpenClone_FTP_Password+":1001"]
          port {
            container_port = 22
          }
          volume_mount {
            name       = "openclone-fs"
            mount_path = "/home/openclone-ftp/OpenCloneFS"
          }
        }
        volume {
          name = "openclone-fs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.openclone_fs_pvc.metadata[0].name
          }
        }
      }
    }
  }
}
# IMPORTANT TODO: when you do security review make sure to think about using both node_ports and load_balancers.
  # NodePort Purpose: Expose a service externally on a specific port of every Kubernetes node.
  # LoadBalancer Purpose: Expose a service externally with a dedicated IP address managed by your cloud provider.
# FYI - in order to expsoe this to your host computer (windows, the one running this dev container, you had to make an entry in kind-config-template.yaml)
resource "kubernetes_service" "openclone_sftp_nodeport" {
  metadata {
    name = "openclone-sftp-nodeport"
  }
  spec {
    selector = {
      pod_id = "openclone-sftp-pod"
    }
    port {
      protocol    = "TCP"
      port        = 22
      target_port = 22
      node_port   = var.sftp_nodeport
    }
    type = "NodePort"
  }
}

################################################################################
######## KIND ##################################################################
################################################################################

# move KIND to longhorn. this was an attempt to get it to work on windows but WSL lacks some linux kernel files that are required for readwritemany. just switch to longhorn for kind and say KIND only works on linux, not windows.

# StorageClass
resource "kubernetes_storage_class" "manual_hostpath" {
  metadata {
    name = "manual-hostpath"
  }
  
  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "Immediate"
  reclaim_policy      = "Retain"
}

# PersistentVolume
resource "kubernetes_persistent_volume" "shared_data_pv" {
  metadata {
    name = "shared-data-pv"
  }
  
  spec {
    capacity = {
      storage = "10Gi"
    }
    
    access_modes = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name = kubernetes_storage_class.manual_hostpath.metadata[0].name
    
    persistent_volume_source {
      host_path {
        path = "/shared-data"
        type = "DirectoryOrCreate"
      }
    }
  }
}