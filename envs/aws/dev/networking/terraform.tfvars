############################################
# envs/aws/dev/networking/terraform.tfvars
# Purpose:
# - DEV values only
############################################

region   = "us-east-1"
env      = "dev"

# Naming for AWS console readability
vpc_name = "ibank-dev-vpc"

# Dev CIDR (small + safe)
vpc_cidr = "10.10.0.0/16"

# Dev cost control
az_count           = 3
single_nat_gateway = true
