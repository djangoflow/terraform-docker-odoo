data "cloudflare_zones" "zones" {
  filter {}
}

locals {
  zones = {for zone in data.cloudflare_zones.zones.zones : zone.name => zone.id}
}

resource "cloudflare_record" "cname" {
  for_each = var.cloudflare_proxy ? var.ingress : {}
  name     = each.key
  type     = "CNAME"
  proxied  = true
  content  = "${var.ingress_hostname}.${var.ingress_domain}"
  zone_id  = local.zones[each.value.domain]
  lifecycle {
    ignore_changes = [zone_id]
  }
}
