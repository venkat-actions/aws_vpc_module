resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames= true 

  tags = merge(
    var.vpc_tags,
    local.common_tags,
    {
        Name= local.common_name
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.igw_tags,
    local.common_tags,
    {
      Name= local.common_name
    }
  )
}

#public_subnets
resource "aws_subnet" "public" {
  count= length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone= local.azs_name[count.index]
  map_public_ip_on_launch= true

  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
      Name= "${local.common_name}-public-${split("-", local.azs_name[count.index])[2]}"  #"us-east-1a
    }
  )
}

