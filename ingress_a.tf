data "cloudflare_zone" "ingress_a" {
  name = var.ingress_domain
}

resource "cloudflare_record" "ingress_a" {
  count   = var.ingress_ip != "" && var.ingress_domain != null && var.ingress_hostname != null ? 1 : 0
  name    = "${var.ingress_hostname}.${var.ingress_domain}"
  type    = "A"
  proxied = false
  value   = var.ingress_ip
  zone_id = data.cloudflare_zone.ingress_a.id
  lifecycle {
    ignore_changes = [zone_id]
  }
}
