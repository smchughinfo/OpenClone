# resource that defines the application deployment
# Define the ClusterIP service (internal communication)
###### add later when multiple pods - used for load balancing resource "kubernetes_service" "openclone-website-clusterip" {
###### add later when multiple pods - used for load balancing   metadata {
###### add later when multiple pods - used for load balancing     name = "openclone-database-clusterip"
###### add later when multiple pods - used for load balancing   }
###### add later when multiple pods - used for load balancing 
###### add later when multiple pods - used for load balancing   spec {
###### add later when multiple pods - used for load balancing     selector = {
###### add later when multiple pods - used for load balancing       pod_id = "openclone-website-pod"  # Updated to match the pod label from the deployment
###### add later when multiple pods - used for load balancing     }
###### add later when multiple pods - used for load balancing 
###### add later when multiple pods - used for load balancing     port {
###### add later when multiple pods - used for load balancing       protocol    = "TCP"
###### add later when multiple pods - used for load balancing       port        = 80
###### add later when multiple pods - used for load balancing       target_port = 80
###### add later when multiple pods - used for load balancing     }
###### add later when multiple pods - used for load balancing 
###### add later when multiple pods - used for load balancing     type = "ClusterIP"  # Internal access only
###### add later when multiple pods - used for load balancing   }
###### add later when multiple pods - used for load balancing }

# Define the NodePort service (external access)
resource "kubernetes_service" "openclone-website-nodeport" {
  metadata {
    name = "openclone-website-nodeport"
  }

  timeouts {
    create = "30m"
  }

  spec {
    selector = {
      pod_id = "openclone-website-pod"  # Updated to match the pod label from the deployment
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
      node_port   = var.website_nodeport  # Manually specifying the NodePort (only for testing purposes)
    }

    type = "NodePort"  # External access
  }
}


resource "kubernetes_deployment" "openclone-website" {
  depends_on = [
    kubernetes_persistent_volume_claim.openclone_fs_pvc,
    null_resource.init_db 
  ]
  
  metadata { name = "openclone-website-deployment" }

  timeouts {
    create = "30m"
  }

  spec {
    replicas = 1                                                     # Number of pod replicas to run  # TODO USE Use a Horizontal Pod Autoscaler (HPA)
    progress_deadline_seconds = 1800 #matches 30m timeout
    selector { match_labels = { pod_id = "openclone-website-pod" } } # must match pod (template.metadata) so kubernetes know which pods this deployment manages
    template {                                                       # this is the pod template 
      metadata { labels = { pod_id = "openclone-website-pod" } }
      spec {
        container {
          image = var.image_name_openclone_website # The container image pulled from your registry.
          name  = "openclone-website"              # The name of the container inside the pod.
          port { container_port = 80 }
          
          env {
            name  = "OpenClone_OpenCloneFS"
            value = "/OpenCloneFS"
          }
          env {
            name  = "OpenClone_JWT_Issuer"
            value = var.openclone_jwt_issuer
          }
          env {
            name  = "OpenClone_JWT_Audience"
            value = var.openclone_jwt_audience
          }
          env {
            name  = "OpenClone_JWT_SecretKey"
            value = var.openclone_jwt_secretkey
          }
          env {
            name  = "OpenClone_SadTalker_HostAddress"
            value = var.openclone_sadtalker_hostaddress
          }
          env {
            name  = "OpenClone_U2Net_HostAddress"
            value = var.openclone_u2net_hostaddress
          }
          env {
            name  = "OpenClone_OpenCloneLogLevel"
            value = var.openclone_opencloneloglevel
          }
          env {
            name  = "OpenClone_SystemLogLevel"
            value = var.openclone_systemloglevel
          }
          env {
            name  = "OpenClone_OPENAI_API_KEY"
            value = var.openclone_openai_api_key
          }
          env {
            name  = "OpenClone_GoogleClientId"
            value = var.openclone_googleclientid
          }
          env {
            name  = "OpenClone_GoogleClientSecret"
            value = var.openclone_googleclientsecret
          }
          env {
            name  = "OpenClone_ElevenLabsAPIKey"
            value = var.openclone_elevenlabsapikey
          }
          env {
            name  = "OpenClone_DefaultConnection"
            value = var.internal_openclone_defaultconnection
          }
          env {
            name  = "OpenClone_LogDbConnection"
            value = var.internal_openclone_logdbconnection
          }
          env {
            name  = "ASPNETCORE_URLS"
            value = "http://+:80"
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

