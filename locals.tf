locals{
    common_tags={
        Project= var.project
        Environment= var.environment
        Terraform= true 
    }
    common_name= "${var.project}-${var.environment}"
}