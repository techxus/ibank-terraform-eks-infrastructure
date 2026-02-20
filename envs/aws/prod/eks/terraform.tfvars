############################################################
# envs/prod/terraform.tfvars
# Production: larger capacity + higher availability.
############################################################

config = {
  region = "us-east-1"
  env    = "prod"

  vpc_cidr = "10.30.0.0/16"
  az_count = 3

  # Prod should not use a single NAT gateway (higher availability).
  enable_nat_gateway = true
  single_nat_gateway = false

  name_prefix = "ibank"
  project_tag = "iBank EKS"

  # Prod may lag a version behind dev until tested
  cluster_version = "1.29"

  # Private-only Kubernetes API in prod
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  node_instance_type = "m6i.large"

  ng1_min     = 3
  ng1_max     = 10
  ng1_desired = 6

  ng2_min     = 2
  ng2_max     = 6
  ng2_desired = 3
}
