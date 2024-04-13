module "cloudfront" {
  for_each        = var.create_cloudfront ? var.ingress : {}
  source          = "djangoflow/cloudfront-odoo/aws"
  hostnames = { (each.key) : each.value.domain }
  origin_hostname = "${var.ingress_hostname}.${var.ingress_domain}"
}
