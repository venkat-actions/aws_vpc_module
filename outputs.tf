output "vpc_info"{
    value= aws_vpc.main.id
}
# output "azs_info"{
#     value= data.aws_availability_zones.available.names
# }