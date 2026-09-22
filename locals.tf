locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = true
  }
  common_name = "${var.project}-${var.environment}"
  azs_name    = slice(data.aws_availability_zones.available.names, 0, 2)
  default_vpc = data.aws_vpc.default_vpc
}