############################################
# envs/aws/dev/networking/main.tf
# Purpose:
# - Call the reusable VPC module
############################################

module "vpc" {
  source = "../../../../modules/aws/vpc"

  region             = var.region
  env                = var.env
  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  single_nat_gateway = var.single_nat_gateway

  tags = {
    Owner = "PlatformTeam"
  }
}
