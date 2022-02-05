resource "aws_lb" "vault" {
  for_each           = var.nlbs
  name               = "${try(each.value.name_prefix, var.name_prefix, null)}-${each.key}"
  internal           = try(each.value.internal, false)
  load_balancer_type = "network"
  subnets            = each.value.subnets
  ip_address_type    = try(each.value.ip_address_type, "dualstack")

  enable_cross_zone_load_balancing = try(each.value.enable_cross_zone_load_balancing, true)

  tags = merge(
    var.tags,
    try(each.value.tags, {})
  )
}

resource "aws_lb_listener" "vault" {
  for_each          = var.nlbs
  load_balancer_arn = aws_lb.vault[each.key].arn
  port              = try(each.value.listener_port, "443")
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault[each.key].arn
  }
}

resource "aws_lb_target_group" "vault" {
  for_each               = var.nlbs
  name_prefix            = "vault-"
  port                   = 8200
  protocol               = "TCP"
  vpc_id                 = var.vpc_id
  target_type            = "instance"
  preserve_client_ip     = true
  connection_termination = true
  deregistration_delay   = 0

  dynamic "health_check" {
    for_each = var.vault_routing_policy == "leader_only" && !var.vault_tls_require_and_verify_client_cert ? [1] : []
    content {
      enabled             = true
      interval            = 10
      path                = "/v1/sys/health"
      protocol            = "HTTPS"
      port                = "traffic-port"
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
  }

  dynamic "health_check" {
    for_each = var.vault_routing_policy == "all" && !var.vault_tls_require_and_verify_client_cert ? [1] : []
    content {
      enabled             = true
      interval            = 10
      path                = "/v1/sys/leader"
      protocol            = "HTTPS"
      port                = "traffic-port"
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
  }

  dynamic "health_check" {
    for_each = var.vault_tls_require_and_verify_client_cert ? [1] : []
    content {
      enabled             = true
      interval            = 10
      protocol            = "TCP"
      port                = "traffic-port"
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
  }
}
