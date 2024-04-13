locals {
  ingress_labels = merge({
    for key, value in var.ingress : replace(key, ".", "-") => {
      host     = key
      dbfilter = value.dbfilter
    }
  }, var.ingress_hostname != null ? {
    (replace(var.ingress_hostname, ".", "-")) = {
      host     = "${var.ingress_hostname}.${var.ingress_domain}"
      dbfilter = ""
    }
  } : {})


  labels = merge({
    "traefik.enable"                                                       = "true"
    "traefik.docker.network"                                               = var.traefik_network.name
    "traefik.http.middlewares.db-ipallowlist.ipallowlist.sourcerange"      = "98.97.75.20/32"
    "traefik.http.middlewares.db-ipallowlist.ipallowlist.ipstrategy.depth" = "1"

    "traefik.http.middlewares.gzip.compress"                               = "true"
    "traefik.http.services.${var.name}-websocket.loadbalancer.server.port" = "8072"
    "traefik.http.services.${var.name}.loadbalancer.server.port"           = "8069"
  }, flatten([
    for key, value in local.ingress_labels : {
      "traefik.http.middlewares.${key}-dbfilter.headers.customrequestheaders.X-Odoo-Dbfilter" = value.dbfilter
      "traefik.http.routers.${key}-db.entrypoints"                                            = "https"
      "traefik.http.routers.${key}-db.middlewares"                                            = "${key}-dbfilter,db-ipallowlist"
      "traefik.http.routers.${key}-db.rule"                                                   = "(Host(`${value.host}`)) && PathPrefix(`/web/database`)|| PathPrefix(`/website/info`)"
      "traefik.http.routers.${key}-db.service"                                                = var.name
      "traefik.http.routers.${key}-db.tls"                                                    = "true"
      "traefik.http.routers.${key}-db.tls.certresolver"                                       = "letsencrypt"
      "traefik.http.routers.${key}-websocket.entrypoints"                                     = "https"
      "traefik.http.routers.${key}-websocket.middlewares"                                     = "${key}-dbfilter"
      "traefik.http.routers.${key}-websocket.rule"                                            = "(Host(`${value.host}`)) && (Path(`/longpolling`) || Path(`/websocket`))"
      "traefik.http.routers.${key}-websocket.service"                                         = "${var.name}-websocket"
      "traefik.http.routers.${key}-websocket.tls"                                             = "true"
      "traefik.http.routers.${key}-websocket.tls.certresolver"                                = "letsencrypt"
      "traefik.http.routers.${key}.entrypoints"                                               = "https"
      "traefik.http.routers.${key}.middlewares"                                               = "${key}-dbfilter,gzip"
      "traefik.http.routers.${key}.rule"                                                      = "Host(`${value.host}`)"
      "traefik.http.routers.${key}.service"                                                   = var.name
      "traefik.http.routers.${key}.tls"                                                       = "true"
      "traefik.http.routers.${key}.tls.certresolver"                                          = "letsencrypt"
    }
  ])...)
}
