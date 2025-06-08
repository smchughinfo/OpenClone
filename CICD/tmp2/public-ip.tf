# vultr-dev is used instead of vultr-prod here. i never finished the multi-environment code (e.g. test.openclone, dev.openclone, www.openclone) and vultr_dev was what i had been using when i decided to cut my losses and just put up an MVP ASAP

################################################################################
######## DOMAIN ################################################################
################################################################################

resource "vultr_dns_domain" "openclone_ai" {
  count = (var.environment == "vultr_dev" || var.environment == "vultr_prod") && var.dns_already_created == "false" ? 1 : 0
  domain = var.openclone_domain_name

  lifecycle {
    prevent_destroy = true
  }
}


################################################################################
######## LOAD BALANCERS ########################################################
################################################################################


resource "kubernetes_service" "openclone_sftp_lb" {
  depends_on = [kubernetes_deployment.openclone_sftp]
  count = (var.environment == "vultr_dev" || var.environment == "vultr_prod") ? 1 : 0

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
  count = (var.environment == "vultr_dev" || var.environment == "vultr_prod") ? 1 : 0

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

data "kubernetes_service" "openclone_database_lb_external_ip" {
  count = (var.environment == "vultr_dev" || var.environment == "vultr_prod") ? 1 : 0
  metadata {
    name = kubernetes_service.openclone_database_lb[0].metadata[0].name
  }
}

data "kubernetes_service" "openclone_sftp_lb_external_ip" {
  count = (var.environment == "vultr_dev" || var.environment == "vultr_prod") ? 1 : 0
  metadata {
    name = kubernetes_service.openclone_sftp_lb[0].metadata[0].name
  }
}

################################################################################
######## DOMAIN BINDING ########################################################
################################################################################

resource "vultr_dns_record" "openclone_ai_root_record" {
  count = (var.environment == "vultr_dev") && var.dns_already_created == "false" ? 1 : 0
  domain = vultr_dns_domain.openclone_ai[0].domain
  name   = "@"
  type   = "A"
  data   = "149.28.35.104" # our vps's ip


  lifecycle {
    prevent_destroy = true
  }
}

resource "vultr_dns_record" "openclone_ai_www_record" {
  count = (var.environment == "vultr_dev") && var.dns_already_created == "false" ? 1 : 0
  domain = vultr_dns_domain.openclone_ai[0].domain
  name   = "www"
  type   = "A"
  data   = "149.28.35.104" # our vps's ip

  lifecycle {
    prevent_destroy = true
  }
}

resource "vultr_dns_record" "openclone_ai_sftp_record" {
  count = (var.environment == "vultr_dev") && var.dns_already_created == "false" ? 1 : 0
  domain = vultr_dns_domain.openclone_ai[0].domain
  name   = "dev.sftp"
  type   = "A"
  data   = data.kubernetes_service.openclone_sftp_lb_external_ip[0].status[0].load_balancer[0].ingress[0].ip

  depends_on = [kubernetes_service.openclone_sftp_lb[0]]

  lifecycle {
    prevent_destroy = true
  }
}

resource "vultr_dns_record" "openclone_ai_database_record" {
  count = (var.environment == "vultr_dev") && var.dns_already_created == "false" ? 1 : 0
  domain = vultr_dns_domain.openclone_ai[0].domain
  name   = "dev.database"
  type   = "A"
  data   = data.kubernetes_service.openclone_database_lb_external_ip[0].status[0].load_balancer[0].ingress[0].ip

  depends_on = [kubernetes_service.openclone_database_lb[0]]

  lifecycle {
    prevent_destroy = true
  }
}

################################################################################
######## EMAIL #################################################################
################################################################################

################################resource "vultr_dns_record" "openclone_mx_1" {
################################  count = (var.environment == "vultr_dev" || var.environment == "vultr_prod") ? 1 : 0
################################  domain = vultr_dns_domain.openclone_ai[0].domain
################################  name   = "@"
################################  type   = "MX"
################################  data   = "mx.zoho.com"
################################  priority = 10
################################
################################  lifecycle {
################################    prevent_destroy = true
################################  }
################################}
################################
################################resource "vultr_dns_record" "openclone_mx_2" {
################################  count = (var.environment == "vultr_dev" || var.environment == "vultr_prod") ? 1 : 0
################################  domain = vultr_dns_domain.openclone_ai[0].domain
################################  name   = "@"
################################  type   = "MX"
################################  data   = "mx2.zoho.com"
################################  priority = 20
################################
################################  lifecycle {
################################    prevent_destroy = true
################################  }
################################}
################################
################################resource "vultr_dns_record" "openclone_mx_3" {
################################  count = (var.environment == "vultr_dev" || var.environment == "vultr_prod") ? 1 : 0
################################  domain = vultr_dns_domain.openclone_ai[0].domain
################################  name   = "@"
################################  type   = "MX"
################################  data   = "mx3.zoho.com"
################################  priority = 50
################################
################################  lifecycle {
################################    prevent_destroy = true
################################  }
################################}
################################
################################resource "vultr_dns_record" "openclone_spf" {
################################  count = (var.environment == "vultr_dev" || var.environment == "vultr_prod") ? 1 : 0
################################  domain = vultr_dns_domain.openclone_ai[0].domain
################################  name   = "@"
################################  type   = "TXT"
################################  data   = "v=spf1 include:zohomail.com ~all"
################################
################################  lifecycle {
################################    prevent_destroy = true
################################  }
################################}
################################
################################resource "vultr_dns_record" "openclone_dkim" {
################################  count = (var.environment == "vultr_dev" || var.environment == "vultr_prod") ? 1 : 0
################################  domain = vultr_dns_domain.openclone_ai[0].domain
################################  name   = "zoho._domainkey"
################################  type   = "TXT"
################################  data   = var.openclone_email_dkim
################################
################################  lifecycle {
################################    prevent_destroy = true
################################  }
################################}
################################
################################resource "vultr_dns_record" "openclone_dmarc" {
################################  count = (var.environment == "vultr_dev" || var.environment == "vultr_prod") ? 1 : 0
################################  domain = vultr_dns_domain.openclone_ai[0].domain
################################  name   = "_dmarc"
################################  type   = "TXT"
################################  data   = "v=DMARC1; p=quarantine; rua=mailto:admin@openclone.com; ruf=mailto:admin@openclone.com; sp=quarantine; adkim=r; aspf=r; pct=100"
################################
################################  lifecycle {
################################    prevent_destroy = true
################################  }
################################}