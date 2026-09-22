resource "aws_vpc_peering_connection" "default" {
  count = var.is_peering_required ? 1 : 0
  #   peer_owner_id = var.peer_owner_id
  peer_vpc_id = local.default_vpc.id
  vpc_id      = aws_vpc.main.id
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  auto_accept = true
  tags = merge(
    var.peering_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-default"
    }
  )
}

#public_peering
resource "aws_route" "public_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = local.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}
#private_peering
resource "aws_route" "private_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = local.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}
#database_peering
resource "aws_route" "database_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = local.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

#default_peering
resource "aws_route" "default" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

