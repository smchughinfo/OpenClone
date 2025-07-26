# SSL/TLS Configuration with NGINX Ingress Controller and Let's Encrypt
# This file contains all resources needed for automatic HTTPS with cert-manager

################################################################################
######## NGINX INGRESS CONTROLLER ##############################################
################################################################################

# NGINX Ingress Controller Namespace
resource "kubernetes_namespace" "ingress_nginx" {
  count = 1
  
  metadata {
    name = "ingress-nginx"
  }
}

# Install NGINX Ingress Controller
resource "null_resource" "install_nginx_ingress" {
  count = 1
  
  depends_on = [kubernetes_namespace.ingress_nginx]
  
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=\"${var.kube_config_path}\" apply --validate=false -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml"
  }
}

# Wait for ingress controller to be ready
resource "null_resource" "wait_for_nginx_ingress" {
  count = 1
  
  depends_on = [null_resource.install_nginx_ingress]
  
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=\"${var.kube_config_path}\" wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=1800s"
  }
}

# Get the external IP of the ingress controller
data "kubernetes_service" "nginx_ingress_controller" {
  count = 1
  
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  
  depends_on = [null_resource.wait_for_nginx_ingress_ip]
}

################################################################################
######## CERT-MANAGER ##########################################################
################################################################################

# cert-manager Namespace
resource "kubernetes_namespace" "cert_manager" {
  count = 1
  
  metadata {
    name = "cert-manager"
  }
}

# Install cert-manager CRDs
resource "null_resource" "install_cert_manager_crds" {
  count = 1
  
  depends_on = [kubernetes_namespace.cert_manager]
  
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=\"${var.kube_config_path}\" apply --validate=false -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml"
  }
}

# Install cert-manager
resource "null_resource" "install_cert_manager" {
  count = 1
  
  depends_on = [null_resource.install_cert_manager_crds]
  
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=\"${var.kube_config_path}\" apply --validate=false -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml"
  }
}

# Wait for cert-manager to be ready
resource "null_resource" "wait_for_cert_manager" {
  count = 1
  
  depends_on = [null_resource.install_cert_manager]
  
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=\"${var.kube_config_path}\" wait --namespace cert-manager --for=condition=ready pod --selector=app.kubernetes.io/instance=cert-manager --timeout=1800s"
  }
}

# Wait for cert-manager CRDs to be fully ready
resource "null_resource" "wait_for_cert_manager_crds" {
  count = 1
  
  depends_on = [null_resource.wait_for_cert_manager]
  
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=\"${var.kube_config_path}\" wait --for condition=established --timeout=1800s crd/clusterissuers.cert-manager.io && sleep 10"
  }
}

################################################################################
######## LETSENCRYPT CLUSTERISSUERS ############################################
################################################################################

# Create Let's Encrypt ClusterIssuer YAML files dynamically
resource "local_file" "letsencrypt_prod_issuer" {
  count = 1
  
  content = <<-EOT
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.letsencrypt_email}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOT
  
  filename = "${path.module}/letsencrypt-prod-issuer.yaml"
}

resource "local_file" "letsencrypt_staging_issuer" {
  count = 1
  
  content = <<-EOT
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${var.letsencrypt_email}
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
EOT
  
  filename = "${path.module}/letsencrypt-staging-issuer.yaml"
}

# Create Let's Encrypt ClusterIssuers
resource "null_resource" "create_letsencrypt_issuers" {
  count = 1
  
  depends_on = [
    null_resource.wait_for_cert_manager_crds,
    local_file.letsencrypt_prod_issuer,
    local_file.letsencrypt_staging_issuer
  ]
  
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=\"${var.kube_config_path}\" apply -f letsencrypt-prod-issuer.yaml"
    working_dir = "${path.module}"
  }
  
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=\"${var.kube_config_path}\" apply -f letsencrypt-staging-issuer.yaml"
    working_dir = "${path.module}"
  }
}

################################################################################
######## WEBSITE INGRESS #######################################################
################################################################################

# Ingress resource for app.clonezone.me with automatic HTTPS
resource "kubernetes_ingress_v1" "website_ingress" {
  count = 1
  
  depends_on = [
    kubernetes_deployment.openclone-website,
    null_resource.wait_for_nginx_ingress,
    null_resource.create_letsencrypt_issuers
  ]
  
  metadata {
    name = "openclone-website-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "cert-manager.io/cluster-issuer"             = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "50m"
    }
  }

  spec {
    tls {
      hosts       = ["app.clonezone.me"]
      secret_name = "app-clonezone-me-tls"
    }

    rule {
      host = "app.clonezone.me"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.openclone-website-nodeport.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

################################################################################
######## NGINX(SSL) LOAD BALANCER RETRY LOGIC ##################################
################################################################################

# Wait for nginx ingress controller to get external IP
resource "null_resource" "wait_for_nginx_ingress_ip" {
  count = 1
  
  depends_on = [null_resource.wait_for_nginx_ingress]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for nginx ingress controller to get external IP..."
      timeout=1800  # 30 minutes
      elapsed=0
      while [ $elapsed -lt $timeout ]; do
        ip=$(kubectl --kubeconfig="${var.kube_config_path}" get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
        if [ -n "$ip" ] && [ "$ip" != "<nil>" ]; then
          echo "Nginx ingress external IP found: $ip"
          exit 0
        fi
        echo "Waiting for nginx ingress external IP... ($elapsed/$timeout seconds)"
        sleep 30
        elapsed=$((elapsed + 30))
      done
      echo "Timeout waiting for nginx ingress external IP"
      exit 1
    EOT
  }
}