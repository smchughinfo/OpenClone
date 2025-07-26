# Kubernetes deployment resource that defines the application deployment
resource "kubernetes_deployment" "openclone-database" {
  depends_on = [ kubernetes_persistent_volume_claim.openclone_fs_pvc ]

  metadata {
    name      = "openclone-database-deployment"
  }

  spec {
    replicas = 1                                                      # Number of pod replicas to run 
    selector { match_labels = { pod_id = "openclone-database-pod" } } # must match pod (template.metadata) so kubernetes know which pods this deployment manages
    template {                                                        # this is the pod template 
      metadata { labels = { pod_id = "openclone-database-pod" } }
      spec {
        node_selector = {
          "vke.vultr.com/node-pool" = var.vultr_cpu_node_pool_label
        }
        
        container {
          image = var.image_name_openclone_database # The container image pulled from your registry.
          name  = "openclone-database"                  # The name of the container inside the pod.
          port { container_port = 5432 }
          env {
            name  = "POSTGRES_PASSWORD"
            value = var.postgres_password
          }
          env {
            name  = "OpenClone_OpenCloneDB_User"
            value = var.openclone_openclonedb_user
          }
          env {
            name  = "OpenClone_OpenCloneDB_Password"
            value = var.openclone_openclonedb_password
          }
          env {
            name  = "OpenClone_OpenCloneDB_Name"
            value = var.openclone_openclonedb_name
          }
          env {
            name  = "OpenClone_LogDB_User"
            value = var.openclone_logdb_user
          }
          env {
            name  = "OpenClone_LogDB_Password"
            value = var.openclone_logdb_password
          }
          env {
            name  = "OpenClone_LogDB_Name"
            value = var.openclone_logdb_name
          }
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

# Define the ClusterIP service (internal communication)
resource "kubernetes_service" "openclone-database-clusterip" {
  metadata {
    name      = "openclone-database-clusterip"
  }

  spec {
    selector = {
      pod_id = "openclone-database-pod"  # Updated to match the pod label from the deployment
    }

    port {
      protocol    = "TCP"
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"  # Internal access only
  }
}

# Define the NodePort service (external access)
resource "kubernetes_service" "openclone-database-nodeport" {
  metadata {
    name      = "openclone-database-nodeport"
  }

  spec {
    selector = {
      pod_id = "openclone-database-pod"  # Updated to match the pod label from the deployment
    }

    port {
      protocol    = "TCP"
      port        = 5432
      target_port = 5432
      node_port = var.database_nodeport
    }

    type = "NodePort"  # External access
  }
}

# Check if database initialization was already completed
data "kubernetes_config_map" "db_init_status" {
  count = 1
  metadata {
    name = "openclone-db-init-status"
  }
  
  # This will fail if ConfigMap doesn't exist, but that's expected
  lifecycle {
    ignore_changes = all
  }
}

resource "null_resource" "init_db" {
  depends_on = [
      kubernetes_deployment.openclone-database, null_resource.init_fs
  ]
  
  # Only run when ConfigMap doesn't exist (triggers change forces re-run)
  triggers = {
    # This will change when ConfigMap state changes
    config_exists = can(data.kubernetes_config_map.db_init_status[0].metadata[0].name) ? "exists" : "missing"
  }
  
  provisioner "local-exec" {
    command = "/scripts/database/database.sh --restore"
  }
}
