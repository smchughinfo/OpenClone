resource "kubernetes_deployment" "utility_container" {
  metadata {
    name = "utility-container"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "utility-container"
      }
    }
    template {
      metadata {
        labels = {
          app = "utility-container"
        }
      }
      spec {
        container {
          name  = "utility-container"
          image = "ubuntu:latest"
          command = [
            "/bin/bash", 
            "-c", 
            <<EOT
              apt-get update && \
              apt-get install -y iputils-ping && \
              apt-get install -y telnet && \
              sleep infinity
            EOT
          ]
          volume_mount {
            name       = "openclone-fs"
            mount_path = "/OpenCloneFS"
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
