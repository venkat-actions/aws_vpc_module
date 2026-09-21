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
