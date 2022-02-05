data "aws_route53_zone" "private" {
  count        = var.route53_private_zone_name != "" ? 1 : 0
  name         = var.route53_private_zone_name
  private_zone = true

}

resource "aws_route53_record" "private_a" {
  count   = var.route53_private_zone_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.private[0].zone_id
  name    = var.vault_dns_domain
  type    = "A"

  weighted_routing_policy {
    weight = 1
  }

  set_identifier = "${var.name_prefix}-${data.aws_region.current.name}"

  alias {
    name                   = module.primary.nlbs.internal.dns_name
    zone_id                = module.primary.nlbs.internal.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "private_a_secondary" {
  count   = var.route53_private_zone_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.private[0].zone_id
  name    = var.vault_dns_domain
  type    = "A"

  weighted_routing_policy {
    weight = 1
  }

  set_identifier = "${var.name_prefix}-${data.aws_region.secondary.name}"

  alias {
    name                   = module.secondary.nlbs.internal.dns_name
    zone_id                = module.secondary.nlbs.internal.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "private_aaaa" {
  count   = var.route53_private_zone_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.private[0].zone_id
  name    = var.vault_dns_domain
  type    = "AAAA"

  weighted_routing_policy {
    weight = 1
  }

  set_identifier = "${var.name_prefix}-${data.aws_region.current.name}"

  alias {
    name                   = module.primary.nlbs.internal.dns_name
    zone_id                = module.primary.nlbs.internal.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "private_aaaa_secondary" {
  count   = var.route53_private_zone_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.private[0].zone_id
  name    = var.vault_dns_domain
  type    = "AAAA"

  weighted_routing_policy {
    weight = 1
  }

  set_identifier = "${var.name_prefix}-${data.aws_region.secondary.name}"

  alias {
    name                   = module.secondary.nlbs.internal.dns_name
    zone_id                = module.secondary.nlbs.internal.zone_id
    evaluate_target_health = true
  }
}
