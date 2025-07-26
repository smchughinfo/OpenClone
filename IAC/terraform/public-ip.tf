# Support for both vultr_dev and vultr_prod environments with subdomain differences

################################################################################
######## DOMAIN ################################################################
################################################################################

resource "vultr_dns_domain" "openclone_ai" {
  count = var.dns_already_created == "false" ? 1 : 0
  domain = var.openclone_domain_name

  lifecycle {
    prevent_destroy = true
  }
}

################################################################################
######## LOAD BALANCERS ########################################################
################################################################################

# LOAD BALANCER FOR WEBSITE
resource "kubernetes_service" "openclone_dev_lb" {
  count = 1
  depends_on = [kubernetes_deployment.openclone-website]
  
  metadata {
    name = "openclone-dev-lb"
  }

  spec {
    selector = {
      pod_id = "openclone-website-pod"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }

  timeouts {
    create = "30m"
  }
}

resource "kubernetes_service" "openclone_sftp_lb" {
  depends_on = [kubernetes_deployment.openclone_sftp]
  count = 1

  metadata {
    name = "openclone-sftp-lb"
  }

  spec {
    selector = {
      pod_id = "openclone-sftp-pod"
    }
    port {
      name        = "sftp"
      port        = 22
      target_port = 22
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }

  timeouts {
    create = "30m"
  }
}

resource "kubernetes_service" "openclone_database_lb" {
  depends_on = [kubernetes_deployment.openclone-database]
  count = 1

  metadata {
    name = "openclone-database-lb"
  }

  spec {
    selector = {
      pod_id = "openclone-database-pod"
    }
    port {
      name        = "database"
      port        = 5432
      target_port = 5432
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }

  timeouts {
    create = "30m"
  }
}

################################################################################
######## PUBLIC IP ADDRESS RESOLUTION ##########################################
################################################################################

data "kubernetes_service" "openclone_dev_lb_external_ip" {
  count = 1
  metadata {
    name = kubernetes_service.openclone_dev_lb[0].metadata[0].name
  }
}

data "kubernetes_service" "openclone_sftp_lb_external_ip" {
  count = 1
  metadata {
    name = kubernetes_service.openclone_sftp_lb[0].metadata[0].name
  }
}

data "kubernetes_service" "openclone_database_lb_external_ip" {
  count = 1
  metadata {
    name = kubernetes_service.openclone_database_lb[0].metadata[0].name
  }
}

################################################################################
######## DOMAIN BINDING ########################################################
################################################################################


resource "vultr_dns_record" "openclone_ai_app_record" {
  count = 1
  domain = var.openclone_domain_name
  name   = var.environment == "vultr_dev" ? "dev.app" : "app"
  type   = "A"
  data   = data.kubernetes_service.nginx_ingress_controller[0].status[0].load_balancer[0].ingress[0].ip

  depends_on = [null_resource.wait_for_nginx_ingress_ip]

  lifecycle {
    prevent_destroy = true
  }
}

resource "vultr_dns_record" "openclone_ai_sftp_record" {
  count = 1
  domain = var.openclone_domain_name
  name   = var.environment == "vultr_dev" ? "dev.sftp" : "sftp"
  type   = "A"
  data   = data.kubernetes_service.openclone_sftp_lb_external_ip[0].status[0].load_balancer[0].ingress[0].ip

  depends_on = [kubernetes_service.openclone_sftp_lb[0]]

  lifecycle {
    prevent_destroy = true
  }
}

resource "vultr_dns_record" "openclone_ai_database_record" {
  count = 1
  domain = var.openclone_domain_name
  name   = var.environment == "vultr_dev" ? "dev.database" : "database"
  type   = "A"

  # these next two lines are for ssl
  data   = data.kubernetes_service.openclone_database_lb_external_ip[0].status[0].load_balancer[0].ingress[0].ip
  depends_on = [kubernetes_service.openclone_database_lb[0]]

  lifecycle {
    prevent_destroy = true
  }
}

