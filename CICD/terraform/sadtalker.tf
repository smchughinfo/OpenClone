# Define the ClusterIP service (internal communication)
 resource "kubernetes_service" "openclone-sadtalker-clusterip" {
   metadata {
     name = "openclone-sadtalker-clusterip"
   }
 
   spec {
     selector = {
       pod_id = "openclone-sadtalker-pod"  # Updated to match the pod label from the deployment
     }
 
     port {
       protocol    = "TCP"
       port        = var.openclone_sadtalker_port
       target_port = var.openclone_sadtalker_port
     }
 
     type = "ClusterIP"  # Internal access only
   }
 }


resource "kubernetes_deployment" "openclone-sadtalker" {
  depends_on = [
    kubernetes_persistent_volume_claim.openclone_fs_pvc,
    null_resource.init_db
  ]
  
  metadata { name = "openclone-sadtalker-deployment" }

  timeouts {
    create = "30m"
  }

  spec {
    replicas = 1                                                     # Number of pod replicas to run  # TODO USE Use a Horizontal Pod Autoscaler (HPA)
    progress_deadline_seconds = 1800 #matches 30m timeout
    selector { match_labels = { pod_id = "openclone-sadtalker-pod" } } # must match pod (template.metadata) so kubernetes know which pods this deployment manages
    template {                                                       # this is the pod template 
      metadata { labels = { pod_id = "openclone-sadtalker-pod" } }
      spec {
        container {
          image = var.image_name_openclone_sadtalker # The container image pulled from your registry.
          name  = "openclone-sadtalker"              # The name of the container inside the pod.
          port { container_port = var.openclone_sadtalker_port}
          
          env {
            name  = "OpenClone_OpenCloneFS"
            value = "/OpenCloneFS"
          }
          env {
            name  = "OpenClone_CUDA_VISIBLE_DEVICES"
            value = ""
          }
          env {
            name  = "OpenClone_DB_Host"
            value = "openclone-database-clusterip"
          }
          env {
            name  = "OpenClone_DB_Port"
            value = "5432" // put this into a variable?
          }
          env {
            name  = "OpenClone_LogDB_Name"
            value = var.openclone_logdb_name
          }
          env {
            name  = "OpenClone_LogDB_User"
            value = var.openclone_logdb_user
          }
          env {
            name  = "OpenClone_LogDB_Password"
            value = var.openclone_logdb_password
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

