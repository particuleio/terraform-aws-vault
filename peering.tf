resource "aws_vpc_peering_connection" "vault" {
  count       = var.vpc_peering_enabled ? 1 : 0
  vpc_id      = var.vpc_id
  peer_vpc_id = var.vpc_secondary_id
  peer_region = data.aws_region.secondary.name
  auto_accept = false

  tags = merge(
    {
      "Name" = var.name_prefix
      "Side" = "Requester"
    },
    var.tags
  )
}

resource "aws_vpc_peering_connection_accepter" "vault_secondary" {
  count    = var.vpc_peering_enabled ? 1 : 0
  provider = aws.secondary

  vpc_peering_connection_id = aws_vpc_peering_connection.vault[0].id
  auto_accept               = true

  tags = merge(
    {
      "Name" = var.name_prefix
      "Side" = "Accepter"
    },
    var.tags
  )
}

resource "aws_vpc_peering_connection_options" "requester" {
  count = var.vpc_peering_enabled ? 1 : 0

  # As options can't be set until the connection has been accepted
  # create an explicit dependency on the accepter.
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.vault_secondary[0].id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "accepter" {
  count    = var.vpc_peering_enabled ? 1 : 0
  provider = aws.secondary

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.vault_secondary[0].id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

# Create routes from requestor to acceptor
resource "aws_route" "requestor" {
  count                     = var.vpc_peering_enabled ? length(data.aws_route_tables.vpc[0].ids) : 0
  route_table_id            = tolist(data.aws_route_tables.vpc[0].ids)[count.index]
  destination_cidr_block    = data.aws_vpc.vpc_secondary[0].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vault[0].id
  depends_on                = [data.aws_route_tables.vpc, aws_vpc_peering_connection.vault]
}

# Create routes from acceptor to requestor
resource "aws_route" "acceptor" {
  provider                  = aws.secondary
  count                     = var.vpc_peering_enabled ? length(data.aws_route_tables.vpc_secondary[0].ids) : 0
  route_table_id            = tolist(data.aws_route_tables.vpc_secondary[0].ids)[count.index]
  destination_cidr_block    = data.aws_vpc.vpc[0].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vault[0].id
  depends_on                = [data.aws_route_tables.vpc_secondary, aws_vpc_peering_connection.vault]
}

resource "aws_security_group_rule" "peering" {
  count = var.vpc_peering_enabled ? 1 : 0

  type              = "ingress"
  from_port         = 8201
  to_port           = 8201
  protocol          = "tcp"
  security_group_id = module.primary.sg.security_group_id
  cidr_blocks       = compact([data.aws_vpc.vpc_secondary[0].cidr_block])
  ipv6_cidr_blocks  = compact([data.aws_vpc.vpc_secondary[0].ipv6_cidr_block])
  description       = "${var.name_prefix}-peering"
}

resource "aws_security_group_rule" "peering_secondary" {
  count    = var.vpc_peering_enabled ? 1 : 0
  provider = aws.secondary

  type              = "ingress"
  from_port         = 8201
  to_port           = 8201
  protocol          = "tcp"
  security_group_id = module.secondary.sg.security_group_id
  cidr_blocks       = compact([data.aws_vpc.vpc[0].cidr_block])
  ipv6_cidr_blocks  = compact([data.aws_vpc.vpc[0].ipv6_cidr_block])
  description       = "${var.name_prefix}-peering"
}
