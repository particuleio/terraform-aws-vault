data "aws_route53_zone" "public" {
  count = var.route53_zone_name != "" ? 1 : 0
  name  = var.route53_zone_name
}

resource "aws_route53_record" "public_a" {
  count   = var.route53_zone_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.public[0].zone_id
  name    = var.vault_dns_domain
  type    = "A"

  weighted_routing_policy {
    weight = 1
  }

  set_identifier = "${var.name_prefix}-${data.aws_region.current.region}"

  alias {
    name                   = module.primary.nlbs.external.dns_name
    zone_id                = module.primary.nlbs.external.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "public_a_secondary" {
  count   = var.route53_zone_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.public[0].zone_id
  name    = var.vault_dns_domain
  type    = "A"

  weighted_routing_policy {
    weight = 1
  }

  set_identifier = "${var.name_prefix}-${data.aws_region.secondary.region}"

  alias {
    name                   = module.secondary.nlbs.external.dns_name
    zone_id                = module.secondary.nlbs.external.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "public_aaaa" {
  count   = var.route53_zone_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.public[0].zone_id
  name    = var.vault_dns_domain
  type    = "AAAA"

  weighted_routing_policy {
    weight = 1
  }

  set_identifier = "${var.name_prefix}-${data.aws_region.current.region}"

  alias {
    name                   = module.primary.nlbs.external.dns_name
    zone_id                = module.primary.nlbs.external.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "public_aaaa_secondary" {
  count   = var.route53_zone_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.public[0].zone_id
  name    = var.vault_dns_domain
  type    = "AAAA"

  weighted_routing_policy {
    weight = 1
  }

  set_identifier = "${var.name_prefix}-${data.aws_region.secondary.region}"

  alias {
    name                   = module.secondary.nlbs.external.dns_name
    zone_id                = module.secondary.nlbs.external.zone_id
    evaluate_target_health = true
  }
}
