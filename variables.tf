variable "name" {
  type = string
}

variable "copy_addons" {
  type = bool
  default = true
}

variable "db" {
  type = object({
    name    = optional(string)
    host    = optional(string)
    network = object({
      name = string
      id   = string
    })
    user     = optional(string)
    password = optional(string)
  })
}

variable "image_name" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "image_platform" {
  default = null # e.g. "linux/amd64"
}

variable "ingress_domain" {
  description = "The domain name where the random (non-cached) origin hostname will be generated"
  type        = string
}

variable "ingress_hostname" {
  description = "The hostname to use instead of the random (non-cached) origin hostname"
  type        = string
}

variable "ingress_ip" {
  description = "The ip address of the ingress hostname.domain to be created in cloudflare"
  type        = string
  default     = null
}

variable "ingress" {
  description = "A map of hostname:ingress objects "
  type        = map(object({
    dbfilter = optional(string, "")
    domain   = string
  }))
  default = null
}

variable "traefik_network" {
  type = object({
    name = string
    id   = string
  })
}

variable "odoo_config" {
  type    = string
  default = <<EOT
[options]
addons_path = /mnt/extra-addons
data_dir = /var/lib/odoo
; admin_passwd =
; csv_internal_sep = ,
; db_maxconn = 64
;db_name =
; db_template = template1
; dbfilter = .*
; debug_mode = False
; email_from = False
; limit_memory_hard = 2684354560
; limit_memory_soft = 2147483648
limit_request = 8192
limit_time_cpu = 120
limit_time_real = 360
list_db = True
; log_db = False
log_handler = :WARN
;log_level = info
; logfile = None
longpolling_port = 8072
max_cron_threads = 1
; osv_memory_age_limit = 1.0
; osv_memory_count_limit = False
proxy_mode = True
server_wide_modules = web, logging_gke
; smtp_password = False
; smtp_port = 25
; smtp_server = localhost
; smtp_ssl = False
; smtp_user = False
workers = 4
; xmlrpc = True
; xmlrpc_interface =
; xmlrpc_port = 8069
; xmlrpcs = True
; xmlrpcs_interface =
; xmlrpcs_port = 8071
EOT
}

variable "create_cloudfront" {
  type    = bool
  default = false
}

variable "cloudflare_proxy" {
  type    = bool
  default = true
}
