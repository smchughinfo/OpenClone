variable "vultr_api_key"                                { default = "" }
variable "vultr_region"                                 { default = "" }        

variable "environment"                                  { default = "" }
variable "kube_config_path"                             { default = "" }
variable "vultr_cluster_label"                          { default = "" }
variable "kubernetes_version"                           { default = "" }
variable "vultr_all_deployments_node_pool_label"        { default = "" }

variable "postgres_password"                            { default = "" }
variable "dns_already_created"                          { default = "" }
variable "openclone_domain_name"                        { default = "" }
variable "openclone_openclonedb_user"                   { default = "" }
variable "openclone_openclonedb_password"               { default = "" }
variable "openclone_openclonedb_name"                   { default = "" }
variable "openclone_logdb_user"                         { default = "" }
variable "openclone_logdb_password"                     { default = "" }
variable "openclone_logdb_name"                         { default = "" }
variable "openclone_jwt_issuer"                         { default = "" }
variable "openclone_jwt_audience"                       { default = "" }
variable "openclone_jwt_secretkey"                      { default = "" }
variable "openclone_opencloneloglevel"                  { default = "" }
variable "openclone_systemloglevel"                     { default = "" }
variable "openclone_ftp_user"                           { default = "" }
variable "openclone_ftp_password"                       { default = "" }

variable "openclone_sadtalker_port"                     { default = "" }
variable "openclone_sadtalker_hostaddress"              { default = "" }
        
variable "openclone_u2net_port"                         { default = "" }
variable "openclone_u2net_hostaddress"                  { default = "" }
        
variable "openclone_openai_api_key"                     { default = "" }
variable "openclone_googleclientid"                     { default = "" }
variable "openclone_googleclientsecret"                 { default = "" }
variable "openclone_elevenlabsapikey"                   { default = "" }
variable "internal_openclone_defaultconnection"         { default = "" }
variable "internal_openclone_logdbconnection"           { default = "" }
        
variable "image_name_openclone_sadtalker"               { default = "" }
variable "image_name_openclone_u-2-net"                 { default = "" }
variable "image_name_openclone_database"                { default = "" }
variable "image_name_openclone_website"                 { default = "" }
        
variable "openclone_email_dkim"                         { default = "" }
        
variable "OpenClone_Root_Dir"                           { default = "" }
        
variable "sftp_nodeport"                                { default = "" }
variable "database_nodeport"                            { default = "" }
variable "website_nodeport"                             { default = "" }

variable "openclone_server_0_ip_address"                          { default = "" }