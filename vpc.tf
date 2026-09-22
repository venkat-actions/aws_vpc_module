resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = merge(
    var.vpc_tags,
    local.common_tags,
    {
      Name = local.common_name
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.igw_tags,
    local.common_tags,
    {
      Name = local.common_name
    }
  )
}

#public_subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs_name[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-public-${split("-", local.azs_name[count.index])[2]}" #"us-east-1a
    }
  )
}

#private_subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.azs_name[count.index]
  # map_public_ip_on_launch= true

  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-private-${split("-", local.azs_name[count.index])[2]}" #"us-east-1a
    }
  )
}

#database_subnets
resource "aws_subnet" "database" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = local.azs_name[count.index]
  # map_public_ip_on_launch= true

  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-database-${split("-", local.azs_name[count.index])[2]}" #"us-east-1a
    }
  )
}

#public_RT
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-public"
    }
  )
}

#private_RT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-private"
    }
  )
}

#database_RT
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-database"
    }
  )
}

#eip
resource "aws_eip" "nat" {
  # instance = aws_instance.web.id
  domain = "vpc"
  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}"
    }
  )
}

#natGW
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

#public_subnet_association
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#private_subnet_association
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

#database_subnet_association
resource "aws_route_table_association" "database" {
  count          = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

#public_route
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  # vpc_peering_connection_id = "pcx-45ff3dc1"
  gateway_id = aws_internet_gateway.main.id
}
#private_route
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  # vpc_peering_connection_id = "pcx-45ff3dc1"
  nat_gateway_id = aws_nat_gateway.main.id
}
#database_route
resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  # vpc_peering_connection_id = "pcx-45ff3dc1"
  nat_gateway_id = aws_nat_gateway.main.id
}







