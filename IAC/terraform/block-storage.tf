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
    storage_class_name = "longhorn-rwx"
  }
}

resource "null_resource" "init_fs" {
  depends_on = [ kubernetes_service.openclone_sftp_lb ]
  provisioner "local-exec" {
    command = "/scripts/openclone-fs/openclone-fs.sh --push_openclone_fs"
  }
}

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
            command = ["sh", "-c", "chown -R 1001:1001 /home/openclone-ftp && ls -la /home/openclone-ftp/"]
          volume_mount {
            name       = "openclone-fs"
            mount_path = "/home/openclone-ftp/OpenCloneFS"
          }
        }
        container {
          name  = "openclone-sftp"
          image = "atmoz/sftp"
          args = ["${var.openclone_ftp_user}:${var.openclone_ftp_password}:1001"]
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

